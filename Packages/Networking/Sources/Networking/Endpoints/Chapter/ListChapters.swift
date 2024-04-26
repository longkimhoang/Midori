//
//  ListChapters.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Foundation

public struct ListChaptersRequest: Encodable {
  public enum Reference: String, Encodable {
    case manga
    case scanlationGroup = "scanlation_group"
    case user
  }

  public struct Order: Encodable {
    public let createdAt: SortOrder?
    public let updatedAt: SortOrder?
    public let publishAt: SortOrder?
    public let readableAt: SortOrder?

    public init(
      createdAt: SortOrder? = nil,
      updatedAt: SortOrder? = nil,
      publishAt: SortOrder? = nil,
      readableAt: SortOrder? = nil
    ) {
      self.createdAt = createdAt
      self.updatedAt = updatedAt
      self.publishAt = publishAt
      self.readableAt = readableAt
    }
  }

  public let limit: Int
  public let offset: Int
  public let includes: [Reference]
  public let order: Order?

  public init(
    limit: Int = 100,
    offset: Int = 0,
    includes: [Reference] = [.scanlationGroup],
    order: Order? = nil
  ) {
    self.limit = limit
    self.offset = offset
    self.includes = includes
    self.order = order
  }
}

public struct ListChaptersResponse: Decodable {
  public let limit: Int
  public let offset: Int
}
