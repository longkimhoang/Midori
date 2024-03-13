//
//  RelationshipCoder.swift
//
//
//  Created by Long Kim on 12/3/24.
//

import MetaCodable

struct RelationshipCoder: HelperCoder {
  func decode(from decoder: any Decoder) throws -> Relationship {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: CodingKeys.type)
    switch type {
    case CoverRelationship.identifier:
      let relationship = try CoverRelationship(from: decoder)
      return relationship
    case AuthorRelationship.identifier:
      let relationship = try AuthorRelationship(from: decoder)
      return relationship
    case MangaRelationship.identifier:
      let relationship = try MangaRelationship(from: decoder)
      return relationship
    case ScanlationGroupRelationship.identifier:
      let relationship = try ScanlationGroupRelationship(from: decoder)
      return relationship
    case ArtistRelationship.identifier:
      let relationship = try ArtistRelationship(from: decoder)
      return relationship
    case UserRelationship.identifier:
      let relationship = try UserRelationship(from: decoder)
      return relationship
    case CreatorRelationship.identifier:
      let relationship = try CreatorRelationship(from: decoder)
      return relationship
    default:
      let context = DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "Couldn't match any cases."
      )
      throw DecodingError.typeMismatch(Relationship.self, context)
    }
  }

  func encode(_ value: Relationship, to encoder: any Encoder) throws {
    let container = encoder.container(keyedBy: CodingKeys.self)
    var typeContainer = container
    switch value {
    case let relationship as CoverRelationship:
      try typeContainer.encode(CoverRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as AuthorRelationship:
      try typeContainer.encode(AuthorRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as MangaRelationship:
      try typeContainer.encode(MangaRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as ScanlationGroupRelationship:
      try typeContainer.encode(ScanlationGroupRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as ArtistRelationship:
      try typeContainer.encode(ArtistRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as UserRelationship:
      try typeContainer.encode(UserRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    case let relationship as CreatorRelationship:
      try typeContainer.encode(CreatorRelationship.identifier, forKey: CodingKeys.type)
      try relationship.encode(to: encoder)
    default:
      break
    }
  }

  enum CodingKeys: String, CodingKey {
    case type
  }
}
