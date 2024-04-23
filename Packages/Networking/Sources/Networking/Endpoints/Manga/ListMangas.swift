//
//  ListMangas.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

public struct ListMangasRequest: Encodable {
  public let limit: Int
  public let offset: Int
  public let createdAtSince: Date?

  public init(
    limit: Int = 100,
    offset: Int = 0,
    createdAtSince: Date? = nil
  ) {
    self.limit = limit
    self.offset = offset
    self.createdAtSince = createdAtSince
  }
}

public struct ListMangasResponse: Decodable {
  public let limit: Int
  public let offset: Int
  public let data: [Manga]

  public init(
    limit: Int,
    offset: Int,
    data: [Manga]
  ) {
    self.limit = limit
    self.offset = offset
    self.data = data
  }
}
