//
//  Chapter.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Chapter: Entity {
    public struct Attributes: Decodable, Sendable {
        public let title: String?
        public let volume: String?
        /// A `nil` usually indicates a oneshot, but ``title`` might provide more context.
        public let chapter: String?
        /// Count of readable images for this chapter
        public let pages: Int
        /// Denotes a chapter that links to an external source.
        public let externalURL: URL?
        public let version: Int
        public let readableAt: Date

        enum CodingKeys: String, CodingKey {
            case title
            case volume
            case chapter
            case pages
            case externalURL = "externalUrl"
            case version
            case readableAt
        }
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
