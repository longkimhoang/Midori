//
//  ExpandableRelationship.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Foundation

/// A  relationship that can be expanded into a complete entity.
public protocol ExpandableRelationship<Expanded>: Relationship {
  associatedtype Expanded: ReferenceExpandable

  var attributes: Expanded.Attributes? { get }
}

extension ExpandableRelationship {
  /// Expands the relationship into a complete entity.
  public var expanded: Expanded? {
    attributes.map { Expanded(id: id, attributes: $0) }
  }
}

extension MangaRelationship: ExpandableRelationship {
  public typealias Expanded = Manga
}

extension CoverRelationship: ExpandableRelationship {
  public typealias Expanded = Cover
}

extension AuthorRelationship: ExpandableRelationship {
  public typealias Expanded = Author
}

extension ArtistRelationship: ExpandableRelationship {
  public typealias Expanded = Author
}
