//
//  NetworkLayerErrorTests.swift
//  
//
//  Created by Tornike on 12/09/2023.
//

import Foundation
import XCTest
import Moya
@testable import Networking

class NetworkLayerErrorTests: XCTestCase {
  func testNetworkLayerErrorReasonEquality() {
    XCTAssertEqual(NetworkLayerErrorReason.unknown, NetworkLayerErrorReason.unknown)
    XCTAssertNotEqual(NetworkLayerErrorReason.unknown, NetworkLayerErrorReason.authorization)
  }

  func testNetworkLayerErrorEquality() {
    let apiErrorItem1 = ApiErrorItem(message: "Error", statusCode: 404, timestamp: "now", path: "/api/")
    let moyaError1 = MoyaError.statusCode(Response(statusCode: 404, data: Data()))

    let apiErrorItem2 = ApiErrorItem(message: "Error", statusCode: 404, timestamp: "now", path: "/api/")
    let moyaError2 = MoyaError.statusCode(Response(statusCode: 404, data: Data()))

    let networkError1 = NetworkLayerError(reason: .statusCode, moyaError: moyaError1, statusCode: 404, apiErrorItem: apiErrorItem1)
    let networkError2 = NetworkLayerError(reason: .statusCode, moyaError: moyaError2, statusCode: 404, apiErrorItem: apiErrorItem2)

    XCTAssertEqual(networkError1, networkError2)
  }

  func testNetworkLayerErrorInequality() {
    let apiErrorItem1 = ApiErrorItem(message: "Error", statusCode: 404, timestamp: "now", path: "/api/")
    let moyaError1 = MoyaError.statusCode(Response(statusCode: 404, data: Data()))

    let apiErrorItem2 = ApiErrorItem(message: "Error", statusCode: 403, timestamp: "now", path: "/api/")
    let moyaError2 = MoyaError.statusCode(Response(statusCode: 403, data: Data()))

    let networkError1 = NetworkLayerError(reason: .statusCode, moyaError: moyaError1, statusCode: 404, apiErrorItem: apiErrorItem1)
    let networkError2 = NetworkLayerError(reason: .authorization, moyaError: moyaError2, statusCode: 403, apiErrorItem: apiErrorItem2)

    XCTAssertNotEqual(networkError1, networkError2)
  }
}
