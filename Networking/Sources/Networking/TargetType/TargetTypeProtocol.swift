//
//  MOETargetType.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

public protocol TargetTypeProtocol: Moya.TargetType, Moya.AccessTokenAuthorizable {
    var mayRunAsBackgroundTask: Bool { get }
    var baseUrlSuffix: String { get }
    var overrideApiVersion: String? { get }
}

public extension TargetTypeProtocol {
    var baseURL: URL {
        return URL(string: "https://example.use-moetargettype")!
    }

    var validationType: ValidationType {
        return .successCodes
    }

    var headers: [String: String]? {
        return [
            "X-Api-Version": apiVersion,
            "Content-Type": "application/json",
            "X-APP": "MOE",
            "Accept": "application/json"
        ]
    }

    var authorizationType: Moya.AuthorizationType? {
        .custom("")
    }

    var mayRunAsBackgroundTask: Bool {
        false
    }

    var baseUrlSuffix: String {
        ""
    }

    var apiVersion: String {
        ""
    }

    var overrideApiVersion: String? {
        nil
    }
}
