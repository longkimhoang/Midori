//
//  Manga.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Domain
import Foundation

public struct Manga: Identifiable, Equatable, Sendable {
  public let id: UUID
  public let title: LocalizedString
  public let description: LocalizedString?
  public let authorName: String
  public let artistName: String?
  public let coverImageThumbnailURL: URL?
  public let coverImageURL: URL?

  public init(
    id: UUID,
    title: LocalizedString,
    description: LocalizedString?,
    authorName: String,
    artistName: String?,
    coverImageThumbnailURL: URL?,
    coverImageURL: URL?
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.authorName = authorName
    self.artistName = artistName
    self.coverImageThumbnailURL = coverImageThumbnailURL
    self.coverImageURL = coverImageURL
  }
}
