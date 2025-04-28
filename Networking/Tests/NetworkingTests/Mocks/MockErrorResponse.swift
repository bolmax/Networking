//
//  File.swift
//  
//
//  Created by Tornike on 13/09/2023.
//

import Foundation

struct MockErrorResponse: Decodable, Equatable {
  let error: String
  let message: String
}
