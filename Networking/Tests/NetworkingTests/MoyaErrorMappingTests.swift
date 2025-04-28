//
//  MoyaErrorMappingTests.swift
//  
//
//  Created by Tornike on 13/09/2023.
//

import Foundation
import XCTest
import Moya
@testable import Networking

class MoyaErrorMappingTests: XCTestCase {
  func testImageMappingError() {
    let moyaError = MoyaError.imageMapping(Response(statusCode: 200, data: Data()))
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.imageMapping)
  }
  
  func testJsonMappingError() {
    let moyaError = MoyaError.jsonMapping(Response(statusCode: 200, data: Data()))
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.jsonMapping)
  }
  
  func testStatusCodeError() {
    let moyaError = MoyaError.statusCode(Response(statusCode: 401, data: Data()))
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.statusCode)
    
    let moyaErrorGeneric = MoyaError.statusCode(Response(statusCode: 400, data: Data()))
    XCTAssertEqual(moyaErrorGeneric.asApiErrorReason, NetworkLayerErrorReason.statusCode)
  }
  
  func testUnderlyingError() {
    let underlyingError = NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
    let moyaError = MoyaError.underlying(underlyingError, nil)
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.underlying)
  }

  func testRequestMappingError() {
    let moyaError = MoyaError.requestMapping("Bad Request")
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.requestMapping)
  }

  func testParameterEncodingError() {
    let moyaError = MoyaError.parameterEncoding(NSError())
    XCTAssertEqual(moyaError.asApiErrorReason, NetworkLayerErrorReason.parameterEncoding)
  }
}
