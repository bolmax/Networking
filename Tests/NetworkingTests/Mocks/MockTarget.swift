//
//  MockTarget.swift
//  
//
//  Created by Tornike on 14/09/2023.
//

import Foundation
import Moya
@testable import Networking

// Mock Target conforming to MOETargetType
struct MockTarget: MOETargetType {

  var baseUrlSuffix: String {
    return "/suffix"
  }

  var path: String {
    return "/path"
  }

  var method: Moya.Method {
    return .get
  }

  var sampleData: Data {
    return Data()
  }

  var task: Task {
    return .requestPlain
  }

  var headers: [String: String]? {
    return ["Authorization": "Bearer token"]
  }
}
