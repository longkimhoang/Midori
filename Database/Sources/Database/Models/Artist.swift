//
//  Artist.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Foundation
import SwiftData

@Model
public class Artist {
  @Attribute(.unique)
  public var artistID: UUID
  public var name: String
  public var imageURL: URL?
  @Relationship(inverse: \Manga.artist)
  public var mangas: [Manga] = []

  public init(
    artistID: UUID,
    name: String,
    imageURL: URL? = nil
  ) {
    self.artistID = artistID
    self.name = name
    self.imageURL = imageURL
  }
}
