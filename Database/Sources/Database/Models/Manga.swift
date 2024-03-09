//
//  Manga.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import Foundation
import SwiftData

@Model
public final class Manga {
  @Attribute(.unique)
  public var mangaID: UUID
  @Attribute(.spotlight)
  public var title: String
  public var coverImageURL: URL?
  public var createdAt: Date
  public var artist: Artist?
  public var author: Author?
  @Relationship(inverse: \Chapter.manga)
  public var chapters: [Chapter] = []

  public init(
    mangaID: UUID,
    title: String,
    coverImageURL: URL? = nil,
    createdAt: Date
  ) {
    self.mangaID = mangaID
    self.title = title
    self.coverImageURL = coverImageURL
    self.createdAt = createdAt
  }
}
