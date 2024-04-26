//
//  RelationshipCoder.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import MetaCodable

struct RelationshipCoder: HelperCoder {
  func decode(from decoder: any Decoder) throws -> any Relationship {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(Kind.self, forKey: .type)
    switch type {
    case .cover:
      return try CoverRelationship(from: decoder)
    case .manga:
      return try MangaRelationship(from: decoder)
    }
  }

  enum Kind: String, Decodable {
    case cover = "cover_art"
    case manga
  }

  enum CodingKeys: String, CodingKey {
    case type
  }
}
