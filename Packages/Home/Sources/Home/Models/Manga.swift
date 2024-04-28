//
//  Manga.swift
//
//
//  Created by Long Kim on 25/4/24.
//

import Domain
import Foundation

public struct Manga: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let name: LocalizedString
  public let description: LocalizedString?
  public let coverImageURL: URL?
  public let authorName: String
  public let artistName: String?

  public init(
    id: UUID,
    name: LocalizedString,
    description: LocalizedString?,
    coverImageURL: URL? = nil,
    authorName: String,
    artistName: String? = nil
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.coverImageURL = coverImageURL
    self.authorName = authorName
    self.artistName = artistName
  }
}
