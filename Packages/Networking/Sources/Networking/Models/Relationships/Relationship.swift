//
//  Relationship.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation

/// A type representing a relationship to other entities of a MangaDex API entity.
public protocol Relationship<Referenced>: Identifiable, Decodable, Sendable {
  associatedtype Referenced: Entity

  /// The identifier of the referenced entity.
  var id: UUID { get }
  /// The attributes of the referenced entity, if avaialble.
  ///
  /// Requests to MangaDex API endpoints can optionally asks for references to other entities.
  /// In that case, the response will contain the attributes of the references requested.
  var attributes: Referenced.Attributes? { get }
}

public extension Relationship {
  /// The referenced entity, if constructable.
  var referenced: Referenced? {
    attributes.map { Referenced(id: id, attributes: $0) }
  }
}

// MARK: - Relationships

public struct CoverRelationship: Relationship {
  public typealias Referenced = Cover

  public let id: UUID
  public let attributes: Cover.Attributes?
}

public struct MangaRelationship: Relationship {
  public typealias Referenced = Manga

  public let id: UUID
  public let attributes: Manga.Attributes?
}

public struct AuthorRelationship: Relationship {
  public typealias Referenced = Author

  public let id: UUID
  public let attributes: Author.Attributes?
}

public struct ArtistRelationship: Relationship {
  public typealias Referenced = Author

  public let id: UUID
  public let attributes: Author.Attributes?
}
