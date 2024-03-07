//
//  Relationship.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Foundation
import MetaCodable

@Codable
@CodedAt("type")
public protocol Relationship {
  var id: UUID { get }
}

@Codable
public struct CoverRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { "cover_art" }

  public let id: UUID
  public let attributes: CoverAttributes?

  public var cover: Cover? {
    attributes.map { Cover(id: id, attributes: $0) }
  }
}

@Codable
public struct AuthorRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { ["author", "artist"] }

  public let id: UUID
  public let attributes: AuthorAttributes?

  public var author: Author? {
    attributes.map { Author(id: id, attributes: $0) }
  }
}

@Codable
public struct MangaRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { "manga" }

  public let id: UUID
  public let attributes: MangaAttributes?
}

@Codable
public struct CreatorRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { "creator" }

  public let id: UUID
}

@Codable
public struct ScanlationGroupRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { "scanlation_group" }

  public let id: UUID
}

@Codable
public struct UserRelationship: Relationship, DynamicCodable {
  public static var identifier: DynamicCodableIdentifier<String> { "user" }

  public let id: UUID
}

extension Collection<Relationship> {
  public func first<T: Relationship & DynamicCodable<String>>(
    _: T.Type,
    matching identifier: String? = nil
  ) -> T? {
    let values = lazy.compactMap { $0 as? T }
    guard let identifier else { return values.first }

    for value in values {
      switch identifier {
      case T.identifier:
        return value
      default:
        continue
      }
    }

    return nil
  }
}
