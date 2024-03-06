//
//  Relationship.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Foundation
import MetaCodable

public struct Relationship: Codable {
  public let id: UUID
  public let attributes: RelationshipAttributes?

  enum CodingKeys: CodingKey {
    case id
    case attributes
    case type
  }

  enum `Type`: String, Decodable {
    case cover = "cover_art"
    case author
    case artist
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)

    let type = try? container.decode(`Type`.self, forKey: .type)
    switch type {
    case .cover:
      self.attributes = nil
    case .author, .artist:
      let attributes = try container.decodeIfPresent(AuthorAttributes.self, forKey: .attributes)
      if let attributes {
        self.attributes = .author(attributes)
      } else {
        self.attributes = nil
      }
    case .none:
      self.attributes = .unknown
    }
  }

  public func encode(to encoder: any Encoder) throws {
    throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Encoding relationships is not supported"))
  }
}

public enum RelationshipAttributes: Decodable {
  case author(AuthorAttributes)
  case artist(AuthorAttributes)
  case cover(CoverAttributes)
  case unknown
}

extension Relationship {
  var cover: Cover? {
    switch attributes {
    case .cover(let coverAttributes):
      Cover(id: id, attributes: coverAttributes)
    default:
      nil
    }
  }

  var author: Author? {
    switch attributes {
    case .author(let authorAttributes):
      Author(id: id, attributes: authorAttributes)
    default:
      nil
    }
  }

  var artist: Author? {
    switch attributes {
    case .artist(let authorAttributes):
      Author(id: id, attributes: authorAttributes)
    default:
      nil
    }
  }
}
