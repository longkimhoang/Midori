//
//  ListMangas.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

public struct ListMangasRequest: Encodable, Sendable {
  public enum Reference: String, Encodable, Sendable {
    case manga
    case cover = "cover_art"
    case author
    case artist
    case tag
    case creator
  }

  public struct Order: Encodable, Sendable {
    public let latestUploadChapter: SortOrder?
    public let followedCount: SortOrder?
    public let createdAt: SortOrder?

    public init(
      latestUploadChapter: SortOrder? = nil,
      followedCount: SortOrder? = nil,
      createdAt: SortOrder? = nil
    ) {
      self.latestUploadChapter = latestUploadChapter
      self.followedCount = followedCount
      self.createdAt = createdAt
    }
  }

  public let limit: Int
  public let offset: Int
  public let ids: [String]?
  public let hasAvailableChapters: Bool
  public let createdAtSince: Date?
  public let includes: [Reference]
  public let order: Order?

  public init(
    limit: Int = 100,
    offset: Int = 0,
    ids: [UUID]? = nil,
    hasAvailableChapters: Bool = true,
    createdAtSince: Date? = nil,
    includes: [Reference] = [.artist, .author, .cover],
    order: Order? = nil
  ) {
    self.limit = limit
    self.offset = offset
    self.ids = ids.map { $0.map { $0.uuidString.lowercased() } }
    self.hasAvailableChapters = hasAvailableChapters
    self.createdAtSince = createdAtSince
    self.includes = includes
    self.order = order
  }
}

public struct ListMangasResponse: Decodable, Sendable {
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
