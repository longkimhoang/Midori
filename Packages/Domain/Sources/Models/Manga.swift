//
//  Manga.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import Foundation
import SwiftData

@Model
public final class Manga {
  @Attribute(.unique) public var mangaID: UUID
  @Attribute(.spotlight) public var title: String
  public var overview: String?
  public var coverImageURL: URL?
  public var createdAt: Date

  public init(
    mangaID: UUID,
    title: String,
    overview: String? = nil,
    coverImageURL: URL? = nil,
    createdAt: Date
  ) {
    self.mangaID = mangaID
    self.title = title
    self.overview = overview
    self.coverImageURL = coverImageURL
    self.createdAt = createdAt
  }
}
