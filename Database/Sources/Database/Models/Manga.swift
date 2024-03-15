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
  public var mangaDescription: String?
  public var coverImageURL: URL?
  public var createdAt: Date
  public var artist: Artist?
  public var author: Author?
  @Relationship(inverse: \Chapter.manga)
  public var chapters: [Chapter] = []

  public init(
    mangaID: UUID,
    title: String,
    description: String?,
    coverImageURL: URL? = nil,
    createdAt: Date
  ) {
    self.mangaID = mangaID
    self.title = title
    mangaDescription = description
    self.coverImageURL = coverImageURL
    self.createdAt = createdAt
  }
}

extension Manga {
  public enum ThumbnailSize: Int {
    case small = 256
    case medium = 512
  }

  public func thumbnailURL(for size: ThumbnailSize = .small) -> URL? {
    coverImageURL.flatMap { URL(string: $0.absoluteString + ".\(size.rawValue).jpg") }
  }
}
