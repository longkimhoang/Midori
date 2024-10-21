//
//  Relationship.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
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
