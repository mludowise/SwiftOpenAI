//
//  LastError.swift
//  
//
//  Created by James Rochabrun on 4/28/24.
//

import Foundation

public struct LastError: Codable, Hashable {
   /// One of server_error or rate_limit_exceeded.
   public let code: String
   /// A human-readable description of the error.
   public let message: String
}
