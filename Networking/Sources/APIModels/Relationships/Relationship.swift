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
  public static let identifier: DynamicCodableIdentifier<String> = "cover_art"

  public let id: UUID
  public let attributes: CoverAttributes?
}

@Codable
public struct AuthorRelationship: Relationship, DynamicCodable {
  public static let identifier: DynamicCodableIdentifier<String> = "author"

  public let id: UUID
  public let attributes: AuthorAttributes?
}

@Codable
public struct ArtistRelationship: Relationship, DynamicCodable {
  public static let identifier: DynamicCodableIdentifier<String> = "artist"

  public let id: UUID
  public let attributes: AuthorAttributes?
}

@Codable
public struct MangaRelationship: Relationship, DynamicCodable {
  public static let identifier: DynamicCodableIdentifier<String> = "manga"

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

public extension Collection<Relationship> {
  /// Returns the first ``Relationship`` matching the type sepecifed.
  ///
  /// Use this method as a convenience helper to get the relationship you want from
  /// the relationships returned when fetching an entity from MangaDex API.
  func first<T: Relationship>(_: T.Type) -> T? {
    lazy.compactMap { $0 as? T }.first
  }
}
