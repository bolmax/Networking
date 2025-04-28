//
//  MoyaErrorMapping.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

extension MoyaError {
    public var asApiErrorReason: NetworkLayerErrorReason {
        switch self {
        case .imageMapping:
            return .imageMapping
        case .jsonMapping:
            return .jsonMapping
        case .stringMapping:
            return .stringMapping
        case .objectMapping:
            return .objectMapping
        case .encodableMapping:
            return .encodableMapping
        case .statusCode:
            if errorCode == 401 {
                return .authorization
            }
            return .statusCode
        case .underlying(let error, _):
            if let afError = error.asAFError, afError.isExplicitlyCancelledError {
                return .canceled
            }
            print(error.localizedDescription)
            return .underlying
        case .requestMapping:
            return .requestMapping
        case .parameterEncoding:
            return .parameterEncoding
        }
    }
}

