//
//  NetworkingProviderTests.swift
//  
//
//  Created by Tornike on 14/09/2023.
//

import Foundation
import XCTest
import Moya
@testable import Networking

class NetworkingProviderTests: XCTestCase {
  var sut: NetworkingProvider<MockMOETarget>!
  var stubbingProvider: MoyaProvider<MockMOETarget>!

  override func setUpWithError() throws {
    stubbingProvider = MoyaProvider<MockMOETarget>(
      stubClosure: MoyaProvider.immediatelyStub,
      plugins: [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
    )

    sut = NetworkingProvider<MockMOETarget>.init(stubClosure: { target in
      return .immediate
    }, accessTokenSource: MockAccessTokenSource())
  }

  override func tearDownWithError() throws {
    sut = nil
    stubbingProvider = nil
  }

  func testSuccessfulRequest() async {
    do {
      let response: MockSuccessResponse = try await sut.request(.someCase)
      XCTAssertEqual(response.id, 1)
    } catch {
      XCTFail("Request should succeed")
    }
  }

  func testFailureDueToDecoding() async {
    do {
      let _: MockErrorResponse = try await sut.request(.someCase)
      XCTFail("Request should fail")
    } catch {
      XCTAssertEqual((error as? NetworkLayerError)?.reason, NetworkLayerErrorReason.objectMapping)
    }
  }

  func testFailureDueToStatusCode() async {
    do {
      let expectedJson: String =
       """
        {
          "error": "testError",
          "message": "testMessage"
        }
       """
      let customEndpointClosure = { (target: MockMOETarget) -> Endpoint in
        return Endpoint(url: URL(target: target).absoluteString,
                        sampleResponseClosure: { .networkResponse(401 , expectedJson.data(using: .utf8)!) },
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
      }

      sut = NetworkingProvider(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, accessTokenSource: MockAccessTokenSource())
      let _: MockErrorResponse = try await sut.request(.someCase)
    } catch {
      XCTAssertEqual((error as? NetworkLayerError)?.reason, NetworkLayerErrorReason.underlying)
    }
  }
}
