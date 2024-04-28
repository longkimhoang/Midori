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
  public var title: LocalizedString
  public var overview: LocalizedString?
  public var cover: Cover?
  public var createdAt: Date

  public init(
    mangaID: UUID = .init(),
    title: LocalizedString,
    overview: LocalizedString? = nil,
    cover: Cover? = nil,
    createdAt: Date = .now
  ) {
    self.mangaID = mangaID
    self.title = title
    self.overview = overview
    self.cover = cover
    self.createdAt = createdAt
  }

  // MARK: Relationships

  @Relationship(inverse: \Chapter.manga) public var chapters: [Chapter] = []
  @Relationship(inverse: \Author.mangas) public var author: Author?
  @Relationship(inverse: \Author.mangas) public var artist: Author?
}
