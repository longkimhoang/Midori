//
//  StatisticsEndpoint.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 1/11/24.
//

import Foundation
import Get

extension MangaDexAPI {
    /// Statistics endpoint.
    public enum Statistics {}
}

extension MangaDexAPI.Statistics {
    /// Manga statistics.
    public struct Manga {
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

    public enum CodingKeys: CodingKey {
        case statistics
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statistics = try container.decode([String: MangaStatistics].self, forKey: .statistics)

        self.statistics = statistics.reduce(into: [:]) { result, element in
            guard let uuid = UUID(uuidString: element.key) else {
                return
            }

            result[uuid] = element.value
        }
    }
}

extension MangaDexAPI.Statistics.Manga {
    public static func list(ids: [UUID]) -> Request<GetMangaStatisticsListResponse> {
        var query: [URLQueryItem] = []
        query.append(contentsOf: ids.queryItems(name: "manga[]"))

        return Request(
            path: Self.basePath,
            query: query.map { ($0.name, $0.value) }
        )
    }
}
