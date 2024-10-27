//
//  MangaServiceLive.swift
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
                try await ingestor.ingestMangas(response.data)
            }
        )
    }
}

@ModelActor
private actor MangaAPIResponseIngestor {
    private var authorIDs: [UUID: PersistentIdentifier] = [:]

    func ingestMangas(_ mangas: [Manga]) throws {
        for manga in mangas {
            let mangaEntity = MangaEntity(
                id: manga.id,
                title: manga.title.defaultVariant.1,
                createdAt: manga.createdAt,
                alternateTitles: manga.altTitles.map(LocalizedString.init),
                synopsis: manga.description.map(LocalizedString.init),
                followCount: 0
            )
            modelContext.insert(mangaEntity)

            if let author = manga.relationship(AuthorRelationship.self).flatMap(\.referenced) {
                if let authorID = authorIDs[author.id] {
                    mangaEntity.author = self[authorID, as: AuthorEntity.self]
                } else {
                    let authorEntity = AuthorEntity(
                        id: author.id,
                        name: author.name,
                        imageURL: author.imageURL
                    )
                    mangaEntity.author = authorEntity
                    modelContext.insert(authorEntity)
                    authorIDs[author.id] = authorEntity.persistentModelID
                }
            }

            if let artist = manga.relationship(ArtistRelationship.self).flatMap(\.referenced) {
                if let artistID = authorIDs[artist.id] {
                    mangaEntity.artist = self[artistID, as: AuthorEntity.self]
                } else {
                    let artistEntity = AuthorEntity(
                        id: artist.id,
                        name: artist.name,
                        imageURL: artist.imageURL
                    )
                    mangaEntity.artist = artistEntity
                    modelContext.insert(artistEntity)
                    authorIDs[artist.id] = artistEntity.persistentModelID
                }
            }
        }

        try modelContext.save()
    }
}
