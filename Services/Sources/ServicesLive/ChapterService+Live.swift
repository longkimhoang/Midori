//
//  ChapterService+Live.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import Foundation
import MangaDexAPIClient
import MidoriServices
import MidoriStorage
import SwiftData

extension ChapterService: DependencyKey {
    public static var liveValue: Self {
        @Dependency(\.modelContainer) var modelContainer
        @Dependency(\.mangaDexAPIClient) var client

        return Self(
            syncLatestChapters: {
                let mangaAPIResponseIngestor =
                    MangaAPIResponseIngestor(modelContainer: modelContainer)
                let chapterAPIResponseIngestor =
                    ChapterAPIResponseIngestor(modelContainer: modelContainer)

                let chaptersRequest = MangaDexAPI.Chapter.list(
                    pagination: .init(limit: 64),
                    order: [.readableAt: .descending]
                )
                let chaptersResponse = try await client.send(chaptersRequest).value

                let mangaIDs = chaptersResponse.data.map(\.id)
                let mangasRequest = MangaDexAPI.Manga.list(
                    pagination: .init(limit: mangaIDs.count),
                    ids: mangaIDs
                )

                let mangasResponse = try await client.send(mangasRequest).value
                let mangaPersistentIDs = try await mangaAPIResponseIngestor.ingestMangas(
                    mangasResponse.data
                )

                let chaptersByMangaID: [PersistentIdentifier: [Chapter]] = chaptersResponse.data
                    .reduce(into: [:]) { result, chapter in
                        guard let manga = chapter.relationship(MangaRelationship.self),
                              let persistentID = mangaPersistentIDs[manga.id]
                        else {
                            return
                        }

                        result[persistentID, default: []].append(chapter)
                    }

                try await chapterAPIResponseIngestor.importChapters(chaptersByMangaID)
            }
        )
    }
}
