//
//  MangaService+Live.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import Foundation
import MangaDexAPIClient
import MidoriServices
import MidoriStorage

extension MangaService: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.mangaDexAPIClient) var client
        @Dependency(\.modelContainer) var modelContainer

        return Self(
            syncPopularMangas: {
                @Dependency(\.calendar) var calendar
                @Dependency(\.date.now) var now
                let ingestor = MangaAPIResponseIngestor(modelContainer: modelContainer)

                let lastMonth = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: now,
                    wrappingComponents: false
                )

                let request = MangaDexAPI.Manga.list(
                    pagination: .init(limit: 10),
                    order: [.followedCount: .descending],
                    createdAtSince: lastMonth
                )
                let response = try await client.send(request).value
                let statistics = try await requestStatistics(for: response.data)

                try await ingestor.importMangas(response.data, statistics: statistics)
            },
            syncRecentlyAddedMangas: { limit, offset in
                let ingestor = MangaAPIResponseIngestor(modelContainer: modelContainer)
                let request = MangaDexAPI.Manga.list(
                    pagination: .init(limit: limit, offset: offset),
                    order: [.createdAt: .descending]
                )
                let response = try await client.send(request).value
                let statistics = try await requestStatistics(for: response.data)

                try await ingestor.importMangas(response.data, statistics: statistics)
            },
            syncMangaWithID: { mangaID in
                let ingestor = MangaAPIResponseIngestor(modelContainer: modelContainer)
                let request = MangaDexAPI.Manga(id: mangaID).get()

                do {
                    let response = try await client.send(request).value
                    // We don't request statistics in parallel because manga might request might return 404
                    let statistics = try await requestStatistics(for: [response.data])

                    try await ingestor.importMangas([response.data], statistics: statistics)
                } catch let error as MangaDexAPIError where error.status == 404 {
                    throw MangaServiceError.mangaNotFound
                }
            }
        )
    }

    private static func requestStatistics(for mangas: [Manga]) async throws -> [UUID: MangaStatistics] {
        @Dependency(\.mangaDexAPIClient) var client
        let request = MangaDexAPI.Statistics.Manga.list(ids: mangas.map(\.id))
        return try await client.send(request).value.statistics
    }
}
