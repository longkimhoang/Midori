//
//  Manga.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APICommon
import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct Manga {
  public typealias Attributes = MangaAttributes

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(SequenceCoder(elementHelper: RelationshipCoder()))
  public let relationships: [Relationship]
}

@Codable
public struct MangaAttributes {
  @CodedBy(LocalizedStringCoder())
  public let title: LocalizedString

  @CodedBy(LocalizedStringCoder())
  public let description: LocalizedString?
}

extension Manga {
  public var coverImageURL: URL? {
    guard let cover = relationships.first(CoverRelationship.self).flatMap(\.cover) else {
      return nil
    }

    return URL(string: "https://uploads.mangadex.org/covers")?.appending(
      components: id.uuidString.lowercased(),
      cover.attributes.fileName
    )
  }

  public var author: Author? {
    relationships.first(AuthorRelationship.self, matching: "author").flatMap(\.author)
  }

  public var artist: Author? {
    relationships.first(AuthorRelationship.self, matching: "artist").flatMap(\.author)
  }
}

extension Manga: Identifiable {}
