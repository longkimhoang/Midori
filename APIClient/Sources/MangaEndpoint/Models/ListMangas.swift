//
//  ListMangas.swift
//
//
//  Created by Long Kim on 28/02/2024.
//

import APICommon
import APIModels
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
  public typealias Order = ListMangasSortOrder

  @Default(10)
  public let limit: Int
  public let offset: Int?
  public let ids: [String]?
  @Default(true) public let hasAvailableChapters: Bool
  @CodedBy(DateCoder(formatter: .api)) public let createdAtSince: Date?
  @Default<[ListMangasReference]>([.cover, .author, .artist])
  public let includes: [ListMangasReference]
  public let order: Order?
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
  public typealias SortOrder = APICommon.SortOrder

  public let latestUploadChapter: SortOrder?
  public let followedCount: SortOrder?
  public let createdAt: SortOrder?
}

extension ListMangas {
  public typealias Parameters = ListMangasParameters
}
