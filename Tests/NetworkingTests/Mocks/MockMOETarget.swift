//
//  File.swift
//  
//
//  Created by Tornike on 13/09/2023.
//

import Foundation
import Moya
@testable import Networking

public enum MockMOETarget: MOETargetType {
  case someCase
  case errorCase
  
  public var authorizationType: AuthorizationType? {
    return .bearer
  }

  public var sampleData: Data {
    switch self {
    case .someCase:
      var json: String =
      """
        {
          "id": 1,
          "name": "John Doe",
          "email": "john.doe@example.com"
        }
      """
      guard let data = json.data(using: .utf8) else {
        fatalError("Could not convert string to Data")
      }
      return data
    case .errorCase:
      var json: String =
       """
        {
          "error": "testError",
          "message": "testMessage"
        }
       """
      guard let data = json.data(using: .utf8) else {
        fatalError("Could not convert string to Data")
      }
      return data
    }
  }
  
  public var baseUrlSuffix: String {
    return "/api/v1"
  }
  
  public var path: String {
    switch self {
    case .someCase, .errorCase:
      return "/someEndpoint"
    }
  }
  
  public var method: Moya.Method {
    switch self {
    case .someCase, .errorCase:
      return .get
    }
  }
  
  public var task: Task {
    switch self {
    case .someCase, .errorCase:
      return .requestPlain
    }
  }
}
