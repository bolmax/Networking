//
//  File.swift
//  
//
//  Created by Tornike on 13/09/2023.
//

import Foundation
@testable import Networking

class MockAccessTokenSource: AccessTokenSource {
  var accessToken: String = "MockToken"
}
