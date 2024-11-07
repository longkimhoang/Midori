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

    @discardableResult
    func importMangas(
        _ mangas: [Manga],
        statistics: [UUID: MangaStatistics] = [:]
    ) throws -> [UUID: PersistentIdentifier] {
        for manga in mangas {
            let mangaEntity = MangaEntity(
                id: manga.id,
                title: manga.title.defaultVariant.1,
                createdAt: manga.createdAt,
                alternateTitles: manga.altTitles.map(LocalizedString.init),
                synopsis: manga.description.map(LocalizedString.init)
            )

            if let statistics = statistics[manga.id] {
                mangaEntity.followCount = statistics.follows
                mangaEntity.rating = statistics.rating.bayesian
            }

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

            if let cover = manga.relationship(CoverRelationship.self).flatMap(\.referenced) {
                let imageURLs = Manga.ImageSize.allCases.map { size in
                    (MangaCoverEntity.ImageSize(size), manga.coverImageURL(with: cover.fileName, size: size))
                }

                let coverEntitiy = MangaCoverEntity(
                    imageURLs: Dictionary(uniqueKeysWithValues: imageURLs),
                    volume: cover.volume
                )
                mangaEntity.currentCover = coverEntitiy
                modelContext.insert(coverEntitiy)
            }
        }

        try modelContext.save()

        let persistentIdentifiers = try persistentIdentifiers(for: mangas)
        return persistentIdentifiers.reduce(into: [:]) { result, identifier in
            guard let manga = self[identifier, as: MangaEntity.self] else { return }
            result[manga.id] = identifier
        }
    }

    private func persistentIdentifiers(for mangas: [Manga]) throws -> [PersistentIdentifier] {
        let mangaIDs = Set(mangas.map(\.id))
        var descriptor = FetchDescriptor<MangaEntity>()
        descriptor.predicate = #Predicate {
            mangaIDs.contains($0.id)
        }

        return try modelContext.fetchIdentifiers(descriptor)
    }
}
