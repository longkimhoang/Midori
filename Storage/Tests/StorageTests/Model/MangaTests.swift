//
//  MangaTests.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Dependencies
import Foundation
import Numerics
@testable import Storage
import Testing

@Suite struct MangaTests {
    @Dependency(\.persistenceContainer) var persistenceContainer

    @Test func savesSuccessfully() throws {
        let id = UUID()
        let date = Date()
        let record = Manga(
            id: id,
            title: "title",
            createdAt: date,
            alternateTitles: ["ja_ro": "こんにちは"]
        )

        let manga = try persistenceContainer.dbWriter.write { db in
            try record.saveAndFetch(db)
        }

        #expect(manga.id == id)
        #expect(manga.title == "title")
        #expect(manga.createdAt.timeIntervalSince1970
            .isApproximatelyEqual(to: date.timeIntervalSince1970))
        #expect(manga.alternateTitles == ["ja_ro": "こんにちは"])
    }

    @Test func fetchesLatestCoverSuccessfully() throws {
        let coverID = UUID()
        let cover = try persistenceContainer.dbWriter.write { db in
            let manga = Manga(id: UUID(), title: "title", createdAt: Date())
            try manga.save(db)

            let cover = MangaCover(
                id: coverID,
                mangaID: manga.id,
                fileName: "fileName",
                volume: nil
            )
            try cover.save(db)

            return try manga.latestCover.fetchOne(db)
        }

        #expect(cover?.id == coverID)
    }

    @Test func fetchesAllCoversSuccessfully() throws {
        let coverIDs: [UUID] = [UUID(), UUID(), UUID()]
        let covers = try persistenceContainer.dbWriter.write { db in
            let manga = Manga(id: UUID(), title: "title", createdAt: Date())
            try manga.save(db)

            for coverID in coverIDs {
                let cover = MangaCover(
                    id: coverID,
                    mangaID: manga.id,
                    fileName: "fileName",
                    volume: nil
                )
                try cover.save(db)
            }

            return try manga.covers.fetchAll(db)
        }

        #expect(covers.map(\.id) == coverIDs)
    }

    @Test func fetchAuthorSuccessfully() throws {
        let authorID = UUID()
        let author = try persistenceContainer.dbWriter.write { db in
            let author = Author(
                id: authorID,
                name: "artist",
                imageURL: URL(string: "https://example.com")
            )
            try author.save(db)

            let manga = Manga(id: UUID(), title: "title", createdAt: Date(), authorID: authorID)
            try manga.save(db)

            return try manga.author.fetchOne(db)
        }

        #expect(author?.id == authorID)
    }

    @Test func fetchArtistSuccessfully() throws {
        let artistID = UUID()
        let artist = try persistenceContainer.dbWriter.write { db in
            let artist = Author(
                id: artistID,
                name: "artist",
                imageURL: URL(string: "https://example.com")
            )
            try artist.save(db)

            let manga = Manga(id: UUID(), title: "title", createdAt: Date(), artistID: artistID)
            try manga.save(db)

            return try manga.artist.fetchOne(db)
        }

        #expect(artist?.id == artistID)
    }
}
