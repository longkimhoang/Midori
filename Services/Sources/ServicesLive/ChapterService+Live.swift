//
//  ChapterService+Live.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import AsyncAlgorithms
import Dependencies
import Foundation
import Get
import MangaDexAPIClient
import MidoriServices
import MidoriStorage
import SwiftData

extension ChapterService: DependencyKey {
    public static var liveValue: Self {
        ChapterService(
            syncLatestChapters: {
                @Dependency(\.mangaDexAPIClient) var client
                let chaptersRequest = MangaDexAPI.Chapter.list(
                    pagination: .init(limit: 64),
                    order: [.readableAt: .descending]
                )
                let chaptersResponse = try await client.send(chaptersRequest).value
                try await importChapters(chaptersResponse.data)
            },
            syncChapterPages: { chapterID in
                @Dependency(\.modelContainer) var modelContainer
                @Dependency(\.mangaDexAPIClient) var client

                let chapterAPIResponseIngestor =
                    ChapterAPIResponseIngestor(modelContainer: modelContainer)

                let request = MangaDexAPI.AtHome.server(chapterID: chapterID).get()
                let serverResponse = try await client.send(request).value

                try await chapterAPIResponseIngestor.importPages(from: serverResponse, for: chapterID)
            }
        )
    }

    static func importChapters(_ chapters: [Chapter], markMangasAsFollowed: Bool = false) async throws {
        @Dependency(\.modelContainer) var modelContainer
        @Dependency(\.mangaDexAPIClient) var client
        let mangaAPIResponseIngestor = MangaAPIResponseIngestor(modelContainer: modelContainer)
        let chapterAPIResponseIngestor = ChapterAPIResponseIngestor(modelContainer: modelContainer)

        let mangaIDs = chapters.compactMap { $0.relationship(MangaRelationship.self).map(\.id) }
        let mangasRequest = MangaDexAPI.Manga.list(pagination: .init(limit: mangaIDs.count), ids: mangaIDs)
        let mangaStatisticsRequest = MangaDexAPI.Statistics.Manga.list(ids: mangaIDs)

        // Convert to streams to use combineLatest
        let mangasResponse = AsyncThrowingStream {
            try await client.send(mangasRequest).value.data
        }.prefix(1)

        let mangaStatisticsResponse = AsyncThrowingStream {
            try await client.send(mangaStatisticsRequest).value.statistics
        }.prefix(1)

        guard
            let (mangas, statistics) = try await combineLatest(
                mangasResponse, mangaStatisticsResponse
            ).first(where: { _ in true })
        else {
            return
        }

        let mangaPersistentIDs = try await mangaAPIResponseIngestor.importMangas(
            mangas,
            statistics: statistics,
            follows: markMangasAsFollowed ? Set(mangaIDs) : []
        )

        let chaptersByMangaID: [PersistentIdentifier: [Chapter]] =
            chapters
            .reduce(into: [:]) { result, chapter in
                guard let manga = chapter.relationship(MangaRelationship.self),
                    let mangaPersistentID = mangaPersistentIDs[manga.id]
                else {
                    return
                }

                result[mangaPersistentID, default: []].append(chapter)
            }

        try await chapterAPIResponseIngestor.importChapters(chaptersByMangaID)
    }
}
