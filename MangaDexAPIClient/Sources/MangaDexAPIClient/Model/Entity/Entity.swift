//
//  Entity.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

/// A type that represents an entity in the MangaDex API.
@dynamicMemberLookup
public protocol Entity<Attributes>: Identifiable, Decodable, Sendable {
    associatedtype Attributes: Decodable

    /// The identifier of the entity.
    var id: UUID { get }
    /// The attributes of the entity.
    var attributes: Attributes { get }
    /// The relationships of the entity.
    var relationships: RelationshipContainer { get }
    /// Constructs the entity from an ID and attributes.
    init(id: UUID, attributes: Attributes)
}

extension Entity {
    public var relationships: RelationshipContainer {
        RelationshipContainer()
    }
}

extension Entity {
    public subscript<T>(dynamicMember keyPath: KeyPath<Attributes, T>) -> T {
        attributes[keyPath: keyPath]
    }
}
