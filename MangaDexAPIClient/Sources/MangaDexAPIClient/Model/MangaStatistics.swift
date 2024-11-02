//
//  MangaStatistics.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 1/11/24.
//

public struct MangaStatistics: Decodable, Sendable {
    public struct Comments: Decodable, Sendable {
        public let threadId: Int
        public let repliesCount: Int
    }

    public struct Rating: Decodable, Sendable {
        public let average: Double?
        public let bayesian: Double
    }

    public let comments: Comments?
    public let rating: Rating
    public let follows: Int
}
