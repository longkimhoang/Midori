//
//  Manga.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Common
import Foundation
import HelperCoders
import MetaCodable

@Codable
@MemberInit
public struct Manga {
  public typealias Attributes = MangaAttributes

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(SequenceCoder(elementHelper: RelationshipCoder()))
  public let relationships: [Relationship]

  public init(id: UUID, attributes: Attributes) {
    self.init(id: id, attributes: attributes, relationships: [])
  }
}

@Codable
public struct MangaAttributes {
  @CodedBy(LocalizedStringCoder())
  public let title: LocalizedString
  @CodedBy(LocalizedStringCoder())
  public let description: LocalizedString?
  @CodedBy(DateCoder(formatter: .api))
  public let createdAt: Date
}

extension Manga {
  public var coverImageURL: URL? {
    guard let cover = relationships.first(CoverRelationship.self).flatMap(\.expanded) else {
      return nil
    }

    return URL(string: "https://uploads.mangadex.org/covers")?.appending(
      components: id.uuidString.lowercased(),
      cover.attributes.fileName
    )
  }

  public var author: Author? {
    relationships.first(AuthorRelationship.self).flatMap(\.expanded)
  }

  public var artist: Author? {
    relationships.first(ArtistRelationship.self).flatMap(\.expanded)
  }
}

extension Manga: Identifiable {}
