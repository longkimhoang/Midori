//
//  Manga.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APICommon
import Foundation
import MetaCodable

@Codable
public struct Manga {
  public typealias Attributes = MangaAttributes

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(RelationshipCoder())
  public let relationships: [Reference]
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
    guard let cover = relationships.lazy.compactMap(\.cover).first else { return nil }
    return URL(string: "https://uploads.mangadex.org/covers")?
      .appending(components: id.uuidString.lowercased(), cover.fileName)
  }

  public var author: Author? {
    relationships.lazy.compactMap(\.author).first
  }

  public var artist: Author? {
    relationships.lazy.compactMap(\.artist).first
  }
}

extension Manga: Identifiable {}
