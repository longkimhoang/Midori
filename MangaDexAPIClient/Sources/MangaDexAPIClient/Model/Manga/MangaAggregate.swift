//
//  MangaAggregate.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 28/11/24.
//

import Foundation

public struct MangaAggregate: Decodable, Sendable {
    public struct Volume: Decodable, Sendable {
        public let volume: String
        public let count: Int
        public let chapters: [String: Chapter]
    }

    public struct Chapter: Decodable, Sendable {
        public let chapter: String
        public let id: UUID
        public let others: [UUID]
        public let count: Int
    }

    public let volumes: [String: Volume]
}
