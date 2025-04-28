//
//  RestApi.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

public final class RestApi {
    var provider: NetworkingProvider<WrappedMultiTarget>

    public init(
        provider: NetworkingProvider<WrappedMultiTarget>
    ) {
        self.provider = provider
    }

    public func request<ResponseType: Decodable>(_ target: TargetTypeProtocol) async throws -> ResponseType {
        return try await provider.request(
            WrappedMultiTarget(target: target)
        )
    }
}
