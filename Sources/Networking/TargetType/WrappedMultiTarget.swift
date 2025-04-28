//
//  MOEMultiTarget.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

public struct WrappedMultiTarget: TargetTypeProtocol {
    
    public var authorizationType: AuthorizationType? {
        guard let target = target as? TargetTypeProtocol else {
            return nil
        }
        return target.authorizationType
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        guard let target = target as? TargetTypeProtocol else {
            return target.baseURL
        }
        return URL(string: "\(target.baseURL)\(target.baseUrlSuffix)")!
    }

    /// The embedded `TargetType`.
    public let target: TargetType

    /// The embedded target's base `URL`.
    public var path: String { target.path }

    /// The HTTP method of the embedded target.
    public var method: Moya.Method { target.method }

    /// The sampleData of the embedded target.
    public var sampleData: Data { target.sampleData }

    /// The `Task` of the embedded target.
    public var task: Task { target.task }

    /// The `ValidationType` of the embedded target.
    public var validationType: ValidationType { target.validationType }

    /// The headers of the embedded target.
    public var headers: [String: String]? { target.headers }

    public init(target target: TargetTypeProtocol) {
        self.target = target
    }
}
