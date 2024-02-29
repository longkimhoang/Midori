//
//  APIError.swift
//
//
//  Created by Long Kim on 26/02/2024.
//

import Foundation
import MetaCodable

@Codable
public struct APIError {
  public let id: UUID
  public let status: Int
  public let title: String
  public let detail: String?
}

@Codable
public struct APIErrorResponse: Error {
  public let errors: [APIError]

  public var localizedDescription: String {
    errors.map(\.title).formatted(.list(type: .and))
  }
}
