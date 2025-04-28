//
//  RestApiTests.swift
//
//
//  Created by Tornike on 13/09/2023.
//

import XCTest
import Moya

@testable import Networking

class RestApiTests: XCTestCase {

  var restApi: RestApi!
  var networkProvider: NetworkingProvider<MOEMultiTarget>! = nil
  var mockTokenSource: AccessTokenSource!

  override func setUp() {
    super.setUp()
    // Initialize the RestApi with mock provider
    mockTokenSource = MockAccessTokenSource()
    networkProvider = NetworkingProvider(stubClosure: MoyaProvider.immediatelyStub, accessTokenSource: mockTokenSource)

    restApi = RestApi(baseURL: URL(string: "https://example.com")!, provider: networkProvider)
  }

  func testInitialization() {
    XCTAssertNotNil(restApi)
  }

  func testRequestSuccess() async {
    // When
    do {
      let response: MockSuccessResponse = try await restApi.request(MockMOETarget.someCase)
      let expectedRresponse = MockSuccessResponse(id: 1, name: "John Doe", email: "john.doe@example.com")
      // T*hen
      XCTAssertEqual(response, expectedRresponse)
    } catch {
      XCTFail("Expected success, but got error: \(error)")
    }
  }

  func testRequestFailure() async {
    // Given
    let expectedJson: String =
     """
      {
        "error": "testError",
        "message": "testMessage"
      }
     """
    // When
    do {
      let customEndpointClosure = { (target: MOEMultiTarget) -> Endpoint in
        return Endpoint(url: URL(target: target).absoluteString,
                        sampleResponseClosure: { .networkResponse(401 , expectedJson.data(using: .utf8)!) },
                        method: target.method,
                        task: target.task,
                        httpHeaderFields: target.headers)
      }

      networkProvider = NetworkingProvider(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub, accessTokenSource: mockTokenSource)
      restApi = RestApi(baseURL: URL(string: "https://example.com")!, provider: networkProvider)
      let _: MockErrorResponse = try await restApi.request(MockMOETarget.someCase)
      XCTFail("Expected failure, but got success")
    } catch {
      XCTAssertNotNil(error as? NetworkLayerError)
    }
  }
}
