//
//  Artist.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Foundation
import SwiftData

@Model
public final class Artist {
  @Attribute(.unique) public var artistID: UUID
  public var name: String
  public var imageURL: URL?

  public init(
    artistID: UUID,
    name: String,
    imageURL: URL? = nil
  ) {
    self.artistID = artistID
    self.name = name
    self.imageURL = imageURL
  }

  // MARK: Relationships

  @Relationship(inverse: \Manga.artist) public var mangas: [Manga] = []
}
