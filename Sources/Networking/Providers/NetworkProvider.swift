//
//  NetworkingProvider.swift
//
//
//  Created by Tornike on 09/09/2023.
//

import Foundation
import Moya
import Alamofire
import UIKit

public protocol RefreshTokenProtocol {
    typealias RefreshTokenCompletion = (_ token: String?) -> Void
    func refreshTokenAsync() async -> String?
    func refreshToken(_ completion: @escaping RefreshTokenCompletion)
}

public protocol NetworkingProviderProtocol {
    associatedtype Target: Moya.TargetType
    func request<ResponseType: Decodable>(
        _ target: Target,
        progress: @escaping ProgressBlock
    ) async throws -> ResponseType
}

public class NetworkingProvider<Target>: NetworkingProviderProtocol where Target: Moya.TargetType {
    
    private let provider: MoyaProvider<Target>
    private let refreshToken: RefreshTokenProtocol?
    
    public init(
        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
        requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        plugins: [PluginType] = [],
        trackInflights: Bool = false,
        refreshToken: RefreshTokenProtocol? = nil
    ) {
        self.provider = MoyaProvider(
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            plugins: plugins,
            trackInflights: trackInflights
        )
        
        self.refreshToken = refreshToken
    }
    
    public func request<ResponseType: Decodable>(_ target: Target, progress: @escaping ProgressBlock = { _ in }) async throws -> ResponseType {
        let asyncRequestWrapper = AsyncMoyaRequestWrapper { [weak self] continuation in
            guard let self = self else {
                return nil
            }
            return self.request(target, progress: progress) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: .success(response))
                case .failure(let moyaError):
                    continuation.resume(returning: .failure(moyaError))
                }
            }
        }
        
        return try await withTaskCancellationHandler(operation: {
            let response = await withCheckedContinuation({ continuation in
                asyncRequestWrapper.perform(continuation: continuation)
            })
            
            switch response {
            case .success(let success):
                do {
                    return try handleSuccess(response: success)
                } catch {
                    guard let moayaError = error as? MoyaError else {
                        throw error
                    }
                    
                    print(moayaError)
                    throw try handleFailure(failure: moayaError)
                }
            case .failure(let failure):
                guard let response = failure.response, response.statusCode == 401 else {
                    throw try handleFailure(failure: failure)
                }
                let token = await refreshToken?.refreshTokenAsync()
                if token == nil {
                    throw try handleFailure(failure: failure)
                }
                let asyncRequestWrapper = AsyncMoyaRequestWrapper { [weak self] continuation in
                    guard let self = self else {
                        return nil
                    }
                    return self.request(target, progress: progress) { result in
                        switch result {
                        case .success(let response):
                            continuation.resume(returning: .success(response))
                        case .failure(let moyaError):
                            continuation.resume(returning: .failure(moyaError))
                        }
                    }
                }
                
                return try await withTaskCancellationHandler(operation: {
                    let response = await withCheckedContinuation({ continuation in
                        asyncRequestWrapper.perform(continuation: continuation)
                    })
                    
                    switch response {
                    case .success(let success):
                        do {
                            return try handleSuccess(response: success)
                        } catch {
                            guard let moayaError = error as? MoyaError else {
                                throw error
                            }
                            
                            print(moayaError)
                            throw try handleFailure(failure: moayaError)
                        }
                    case .failure(let failure):
                        throw try handleFailure(failure: failure)
                    }
                }, onCancel: {
                    asyncRequestWrapper.cancel()
                })

            }
        }, onCancel: {
            asyncRequestWrapper.cancel()
        })
    }
    
    private func handleFailure(failure: MoyaError) throws -> NetworkLayerError {
        var errorItem: ApiErrorItem?
        
        switch failure.asApiErrorReason {
        case .objectMapping:
            return NetworkLayerError(reason: failure.asApiErrorReason, moyaError: failure, statusCode: failure.errorCode, apiErrorItem: errorItem)
        default:
            break
        }
        
        if let response = failure.response {
            let errorsDictionary = try response.mapJSON()
            let errorJSON = try JSONSerialization.data(withJSONObject: errorsDictionary, options: [])
            
            errorItem = (try? JSONDecoder().decode(ApiErrorItem.self, from: errorJSON)) ?? nil
        }
        
        return NetworkLayerError(
            reason: failure.asApiErrorReason,
            moyaError: failure,
            statusCode: failure.errorCode,
            apiErrorItem: errorItem
        )
    }
    
    private func handleSuccess<ResponseType: Decodable>(response: Response) throws -> ResponseType {
        let filteredResponse = try response.filterSuccessfulStatusCodes()
        return try filteredResponse.map(ResponseType.self)
    }
    
    private func request(_ target: Target, callbackQueue: DispatchQueue? = .none, progress: ProgressBlock? = .none, completion: @escaping Completion) -> Cancellable {
        return provider.request(
            target,
            callbackQueue: callbackQueue,
            progress: progress,
            completion: completion
        )
    }
}
