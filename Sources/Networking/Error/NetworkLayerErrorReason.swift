//
//  NetworkLayerErrorReason.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

public enum NetworkLayerErrorReason: Equatable {
    case unknown
    case canceled
    case authorization
    case imageMapping
    case jsonMapping
    case stringMapping
    case objectMapping
    case encodableMapping
    case statusCode
    case underlying
    case requestMapping
    case parameterEncoding
}

public struct ApiErrorItem: Codable, Equatable {
    public let message: String
    public let statusCode: Int
    public let timestamp: String
    public let path: String
}

public struct NetworkLayerError: Error {
    public let reason: NetworkLayerErrorReason
    public let moyaError: MoyaError
    public let statusCode: Int
    public let apiErrorItem: ApiErrorItem?
}

extension NetworkLayerError: Equatable {
    public static func == (lhs: NetworkLayerError, rhs: NetworkLayerError) -> Bool {
        return lhs.statusCode == rhs.statusCode && lhs.reason == rhs.reason
    }
}
