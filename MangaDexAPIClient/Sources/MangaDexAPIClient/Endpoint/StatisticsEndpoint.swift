//
//  StatisticsEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 1/11/24.
//

import Foundation
import Get

public extension MangaDexAPI {
    /// Statistics endpoint.
    enum Statistics {}
}

public extension MangaDexAPI.Statistics {
    /// Manga statistics.
    struct Manga {
        static let basePath = "statistics/manga"
        let path: String

        public init(id: UUID) {
            path = "\(Self.basePath)/\(id.uuidString.lowercased())"
        }
    }
}

// MARK: - Get mangas statistics

public struct GetMangaStatisticsListResponse: Decodable, Sendable {
    public let statistics: [UUID: MangaStatistics]
}

public extension MangaDexAPI.Statistics.Manga {
    static func list(ids: [UUID]) -> Request<GetMangaStatisticsListResponse> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: ids.queryItems)

        return Request(
            path: Self.basePath,
            query: query.map { ($0.name, $0.value) }
        )
    }
}
