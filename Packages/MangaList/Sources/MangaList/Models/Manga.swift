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
  public let name: String
  public let description: LocalizedString?
  public let authorName: String
  public let artistName: String?

  public init(
    id: UUID,
    name: String,
    description: LocalizedString?,
    authorName: String,
    artistName: String?
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.authorName = authorName
    self.artistName = artistName
  }
}
