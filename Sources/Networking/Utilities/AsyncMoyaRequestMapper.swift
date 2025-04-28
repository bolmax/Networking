//
//  AsyncMoyaRequestWrapper.swift
//  
//
//  Created by Tornike on 08/09/2023.
//

import Foundation
import Moya

class AsyncMoyaRequestWrapper {
  internal typealias MoyaContinuation = CheckedContinuation<Result<Response, MoyaError>, Never>

  var performRequest: (MoyaContinuation) -> Moya.Cancellable?
  var cancellable: Moya.Cancellable?

  init(_ performRequest: @escaping (MoyaContinuation) -> Moya.Cancellable?) {
      self.performRequest = performRequest
  }

  func perform(continuation: MoyaContinuation) {
      cancellable = performRequest(continuation)
  }

  func cancel() {
      cancellable?.cancel()
  }
}
