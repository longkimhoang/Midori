//
//  Manga.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Manga: Entity {
    public struct Attributes: Decodable, Sendable {
        public let title: LocalizedString
        @LossyDecodable public var description: LocalizedString?
        public let createdAt: Date
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
