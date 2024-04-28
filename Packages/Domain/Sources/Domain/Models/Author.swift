//
//  Author.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Foundation
import SwiftData

@Model
public final class Author {
  @Attribute(.unique) public var authorID: UUID
  public var name: String
  public var imageURL: URL?

  public init(
    authorID: UUID,
    name: String,
    imageURL: URL? = nil
  ) {
    self.authorID = authorID
    self.name = name
    self.imageURL = imageURL
  }

  // MARK: Relationships

  @Relationship(inverse: \Manga.author) public var mangas: [Manga] = []
}
