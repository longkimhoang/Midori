//
//  MangaAPIResponseIngestor.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Foundation
import MangaDexAPIClient
import MidoriStorage
import SwiftData

@ModelActor
actor MangaAPIResponseIngestor {
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
