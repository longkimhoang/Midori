//
//  ListMangas.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import APIModels
import Common
import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct ListMangas {
  public let limit: Int
  public let offset: Int
  @CodedAt("data") public let mangas: [Manga]
}

// MARK: - Request

@Codable
@MemberInit
public struct ListMangasParameters {
  @Default(10) public let limit: Int
  public let offset: Int?
  public let ids: [String]?
  @Default(true) public let hasAvailableChapters: Bool
  @CodedBy(DateCoder(formatter: .api)) public let createdAtSince: Date?
  @Default<[ListMangasReference]>([.cover, .author, .artist])
  public let includes: [ListMangasReference]
  public let order: ListMangasSortOrder?
}

public enum ListMangasReference: String, Codable {
  case manga
  case cover = "cover_art"
  case author
  case artist
  case tag
  case creator
}

@Codable
@MemberInit
public struct ListMangasSortOrder {
  public let latestUploadChapter: Common.SortOrder?
  public let followedCount: Common.SortOrder?
  public let createdAt: Common.SortOrder?
}
