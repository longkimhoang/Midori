//
//  MangaEndpointTests.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get
import Testing

@testable import MangaDexAPIClient

@Suite("Manga endpoint requests")
struct MangaEndpointTests {
    @Suite("Get Manga List")
    struct GetMangaListTests {
        let client = APIClient.mangaDex()

        @Test("Default parameters")
        func requestWithDefaultParameters() async throws {
            let request = MangaDexAPI.Manga.list(pagination: Pagination(limit: 10))
            let urlRequest = try await client.makeURLRequest(for: request)
            #expect(
                urlRequest.url
                    == URL(
                        string: """
                        https://api.mangadex.org/manga?limit=10&includes[]=artist&includes[]=author&includes[]=cover_art
                        """
                    )
            )
        }

        @Test("Custom parameters")
        func requestWithCustomParameters() async throws {
            let date = Date(timeIntervalSince1970: 0)
            let ids = [
                UUID(uuidString: "0216fa10-6754-4f83-87d4-cfad4112d27b")!,
                UUID(uuidString: "bb11cb03-3238-4f28-8e57-8e041b22ef37")!,
            ]

            let request = MangaDexAPI.Manga.list(
                pagination: Pagination(limit: 50, offset: 10),
                order: [.followedCount: .descending],
                includes: [.creator],
                createdAtSince: date,
                ids: ids
            )
            let urlRequest = try await client.makeURLRequest(for: request)
            #expect(
                urlRequest.url
                    == URL(
                        string: """
                        https://api.mangadex.org/manga?limit=50&offset=10&order[followedCount]=desc&\
                        includes[]=creator&createdAtSince=1970-01-01T00:00:00&\
                        ids[]=0216fa10-6754-4f83-87d4-cfad4112d27b&ids[]=bb11cb03-3238-4f28-8e57-8e041b22ef37
                        """
                    )
            )
        }
    }
}
