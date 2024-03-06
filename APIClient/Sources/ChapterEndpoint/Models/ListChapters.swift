//
//  ListChapters.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import APICommon
import APIModels
import MetaCodable

@Codable
public struct ListChapters {
  public let limit: Int
  public let offset: Int
  public let total: Int
  @CodedAt("data") public let chapters: [Chapter]
}

// MARK: - Request

@Codable
@MemberInit
public struct ListChaptersParameters {
  public typealias Order = ListChaptersSortOrder

  @Default(10)
  public let limit: Int
  public let offset: Int?
  public let includes: [ListChaptersReference]?
  public let order: Order
}

public enum ListChaptersReference: String, Codable {
  case manga
  case scanlationGroup = "scanlation_group"
  case user
}

@Codable
@MemberInit
public struct ListChaptersSortOrder {
  public let createdAt: SortOrder?
  public let updatedAt: SortOrder?
  public let publishAt: SortOrder?
  public let readableAt: SortOrder?
}

extension ListChapters {
  public typealias Parameters = ListChaptersParameters
}
