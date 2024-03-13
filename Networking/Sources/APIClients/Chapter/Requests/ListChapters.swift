//
//  ListChapters.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import APIModels
import Common
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
  @Default(10) public let limit: Int
  public let offset: Int?
  public let includes: [ListChaptersReference]?
  public let order: ListChaptersSortOrder?
}

public enum ListChaptersReference: String, Codable {
  case manga
  case scanlationGroup = "scanlation_group"
  case user
}

@Codable
@MemberInit
public struct ListChaptersSortOrder {
  public let createdAt: Common.SortOrder?
  public let updatedAt: Common.SortOrder?
  public let publishAt: Common.SortOrder?
  public let readableAt: Common.SortOrder?
}
