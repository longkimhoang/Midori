//
//  Author.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import Foundation
import SwiftData

@Model
public class Author {
  @Attribute(.unique)
  public var authorID: UUID
  public var name: String
  public var imageURL: URL?
  @Relationship(inverse: \Manga.author)
  public var mangas: [Manga] = []

  public init(
    authorID: UUID,
    name: String,
    imageURL: URL? = nil
  ) {
    self.authorID = authorID
    self.name = name
    self.imageURL = imageURL
  }
}
