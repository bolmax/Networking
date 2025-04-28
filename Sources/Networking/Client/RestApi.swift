//
//  RestApi.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

public final class RestApi {
    var provider: NetworkingProvider<MOEMultiTarget>

    public init(
        provider: NetworkingProvider<MOEMultiTarget>
    ) {
        self.provider = provider
    }

    public func request<ResponseType: Decodable>(_ target: MOETargetType) async throws -> ResponseType {
        return try await provider.request(
            MOEMultiTarget(target: target)
        )
    }
}
