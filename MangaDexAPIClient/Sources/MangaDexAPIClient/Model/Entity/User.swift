//
//  User.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 28/12/24.
//

import Foundation

public struct User: Entity {
    public struct Attributes: Decodable, Sendable {
        public let username: String
        public let roles: [String]
        public let version: Int
    }

    public let id: UUID
    public let attributes: Attributes

    public init(id: UUID, attributes: Attributes) {
        self.id = id
        self.attributes = attributes
    }
}
