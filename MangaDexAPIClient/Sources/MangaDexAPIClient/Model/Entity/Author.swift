//
//  Author.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Author: Entity {
    public struct Attributes: Decodable, Sendable {
        public let name: String
        public let imageURL: URL?
        @LossyDecodable public var biography: LocalizedString?
    }

    public let id: UUID
    public let attributes: Attributes
    public let relationships: RelationshipContainer

    public init(id: UUID, attributes: Attributes) {
        self.id = id
        self.attributes = attributes
        relationships = RelationshipContainer()
    }
}
