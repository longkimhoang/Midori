//
//  MangaRepositoryTests.swift
//  Storage
//
//  Created by Long Kim on 23/10/24.
//

import Dependencies
import Foundation
import MidoriModels
@testable import Storage
import Testing

@Suite("MangaRepository")
struct MangaRepositoryTests {
    @Dependency(\.persistenceContainer.dbWriter) var dbWriter
    let repository = MangaRepository.liveValue

    @Test func fetchPopularMangas() async throws {
        let mangaIDs = [UUID(), UUID()]
        let authorID = UUID()
        let artistID = UUID()

        try await dbWriter.write { db in
            let author = Author(id: authorID, name: "author")
            try author.save(db)

            let artist = Author(id: artistID, name: "artist")
            try artist.save(db)

            let mangas = [
                Manga(
                    id: mangaIDs[0],
                    title: "title",
                    createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                    alternateTitles: [
                        .init(language: "en", value: "alternate title"),
                        .init(language: "ja-ro", value: "こんにちは"),
                    ],
                    followCount: 1000,
                    authorID: author.id,
                    artistID: artist.id
                ),
                Manga(
                    id: mangaIDs[1],
                    title: "title2",
                    createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                    followCount: 400,
                    authorID: author.id
                ),
                Manga(
                    id: UUID(),
                    title: "title3",
                    // slightly over 1 month
                    createdAt: Date(timeIntervalSinceReferenceDate: -2_668_410),
                    authorID: author.id,
                    artistID: artist.id
                ),
            ]
            try mangas.forEach { try $0.save(db) }
        }

        try await confirmation("Fetched popular mangas") { fetched in
            try await withDependencies {
                $0.calendar = Calendar(identifier: .gregorian)
                $0.date = .constant(Date(timeIntervalSinceReferenceDate: 10000))
            } operation: {
                for try await result in repository.fetchPopularMangas().first().values {
                    let expected = [
                        Manga(
                            id: mangaIDs[0],
                            title: "title",
                            createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                            followCount: 1000,
                            alternateTitles: [
                                .init(defaultVariant: .init(
                                    languageCode: "en",
                                    value: "alternate title"
                                )),
                                .init(defaultVariant: .init(
                                    languageCode: "ja-ro",
                                    value: "こんにちは"
                                )),
                            ],
                            author: .init(id: authorID, name: "author"),
                            artist: .init(id: artistID, name: "artist")
                        ),
                        Manga(
                            id: mangaIDs[1],
                            title: "title2",
                            createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                            followCount: 400,
                            author: .init(id: authorID, name: "author")
                        ),
                    ]

                    #expect(result == expected)
                    fetched()
                }
            }
        }
    }

    @Test func saveMangas() async throws {
        let mangaIDs = [UUID(), UUID()]
        let authorID = UUID()
        let artistID = UUID()

        try await dbWriter.write { db in
            let author = Author(id: authorID, name: "author")
            try author.save(db)

            let artist = Author(id: artistID, name: "artist")
            try artist.save(db)
        }

        let input = [
            Manga(
                id: mangaIDs[0],
                title: "title",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                followCount: 1000,
                alternateTitles: [
                    .init(defaultVariant: .init(
                        languageCode: "en",
                        value: "alternate title"
                    )),
                    .init(defaultVariant: .init(
                        languageCode: "ja-ro",
                        value: "こんにちは"
                    )),
                ],
                author: .init(id: authorID, name: "author"),
                artist: .init(id: artistID, name: "artist")
            ),
            Manga(
                id: mangaIDs[1],
                title: "title2",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                followCount: 400,
                author: .init(id: authorID, name: "author")
            ),
        ]

        try await repository.saveMangas(mangas: input)

        let mangas = try await dbWriter.read { db in
            try Manga.fetchAll(db)
        }

        let expected = [
            Manga(
                id: mangaIDs[0],
                title: "title",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                alternateTitles: [
                    .init(language: "en", value: "alternate title"),
                    .init(language: "ja-ro", value: "こんにちは"),
                ],
                followCount: 1000,
                authorID: authorID,
                artistID: artistID
            ),
            Manga(
                id: mangaIDs[1],
                title: "title2",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                followCount: 400,
                authorID: authorID
            ),
        ]

        #expect(mangas == expected)
    }
}
