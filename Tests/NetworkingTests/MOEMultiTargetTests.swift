//
//  MOEMultiTargetTests.swift
//  
//
//  Created by Tornike on 14/09/2023.
//

import Foundation
import XCTest
@testable import Networking // Replace with your actual project name
import Moya

class MOEMultiTargetTests: XCTestCase {
  var baseURL: URL!
  var mockTarget: MockTarget!
  var multiTarget: MOEMultiTarget!

  override func setUp() {
    super.setUp()
    baseURL = URL(string: "https://base.example.com")!
    mockTarget = MockTarget()
    multiTarget = MOEMultiTarget(withBaseUrl: baseURL, andTarget: mockTarget)
  }

  override func tearDown() {
    baseURL = nil
    mockTarget = nil
    multiTarget = nil
    super.tearDown()
  }

  func testBaseURL() {
    let expectedURL = URL(string: "https://base.example.com/suffix")!
    XCTAssertEqual(multiTarget.baseURL, expectedURL)
  }

  func testPath() {
    XCTAssertEqual(multiTarget.path, mockTarget.path)
  }

  func testMethod() {
    XCTAssertEqual(multiTarget.method, mockTarget.method)
  }

  func testSampleData() {
    XCTAssertEqual(multiTarget.sampleData, mockTarget.sampleData)
  }

  func testHeaders() {
    XCTAssertEqual(multiTarget.headers, mockTarget.headers)
  }
}
