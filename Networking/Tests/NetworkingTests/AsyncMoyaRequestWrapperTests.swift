//
//  AsyncMoyaRequestWrapperTests.swift
//  
//
//  Created by Tornike on 14/09/2023.
//

import Foundation
import XCTest
@testable import Networking
import Moya

class AsyncMoyaRequestWrapperTests: XCTestCase {
  typealias SwiftTask = _Concurrency.Task

  var wrapper: AsyncMoyaRequestWrapper!
  var mockCancellable: MockCancellable!

  override func setUp() {
    super.setUp()
    let expectation = self.expectation(description: "Perform should complete")
    mockCancellable = MockCancellable()

    wrapper = AsyncMoyaRequestWrapper { continuation in
      continuation.resume(returning: .success(Response(statusCode: 200, data: Data())))
      return self.mockCancellable
    }

    SwiftTask {
      _ = await withCheckedContinuation { continuation in
        self.wrapper.perform(continuation: continuation)
      }

      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0, handler: nil)
  }

  override func tearDown() {
    wrapper = nil
    mockCancellable = nil
    super.tearDown()
  }

  func testPerform() {
    let expectation = self.expectation(description: "Perform should complete")

    SwiftTask {
      _ = await withCheckedContinuation { continuation in
        self.wrapper.perform(continuation: continuation)
      }

      expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0, handler: nil)
  }

  func testCancel() {
    XCTAssertNotNil(wrapper.cancellable, "Cancellable should be set")
    wrapper.cancel()
    XCTAssertTrue(mockCancellable.isCancelled)
  }
}

// Mock Cancellable
class MockCancellable: Cancellable {
  private(set) var isCancelled = false

  func cancel() {
    isCancelled = true
  }
}
