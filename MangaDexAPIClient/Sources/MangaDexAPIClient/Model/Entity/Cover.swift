//
//  Cover.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Cover: Entity {
    public struct Attributes: Decodable, Sendable {
        public let locale: String
        public let fileName: String
        public let volume: String?
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
