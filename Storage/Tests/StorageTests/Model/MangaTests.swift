//
//  MangaTests.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Dependencies
import Foundation
@testable import MidoriStorage
import Numerics
import SwiftData
import Testing

@Suite("Manga model")
struct MangaTests {
    @Dependency(\.modelContainer) var modelContainer

    @Test func savesSuccessfully() throws {
        let context = ModelContext(modelContainer)

        let id = UUID()
        let date = Date()
        let manga = MangaEntity(
            id: id,
            title: "title",
            createdAt: date,
            alternateTitles: [.init(localizedVariants: ["ja_ro": "こんにちは"])]
        )

        context.insert(manga)

        #expect(throws: Never.self) {
            try context.save()
        }
    }

    @Test func fetchesLatestCoverSuccessfully() throws {
        let context = ModelContext(modelContainer)
        let coverID = UUID()

        let manga = MangaEntity(id: UUID(), title: "title", createdAt: Date())
        context.insert(manga)

        let cover = MangaCoverEntity(
            id: coverID,
            fileName: "fileName",
            volume: nil
        )
        cover.manga = manga
        context.insert(cover)

        manga.currentCover = cover

        #expect(throws: Never.self) {
            try context.save()
        }

        #expect(manga.currentCover?.id == coverID)
    }

    @Test func fetchesAllCoversSuccessfully() throws {
        let context = ModelContext(modelContainer)
        let coverIDs: [UUID] = [UUID(), UUID(), UUID()]
        let manga = MangaEntity(id: UUID(), title: "title", createdAt: Date())
        context.insert(manga)

        for coverID in coverIDs {
            let cover = MangaCoverEntity(
                id: coverID,
                fileName: "fileName",
                volume: nil
            )
            cover.manga = manga
            context.insert(cover)
        }

        #expect(throws: Never.self) {
            try context.save()
        }

        #expect(manga.covers.map(\.id).sorted() == coverIDs.sorted())
    }

    @Test func fetchAuthorSuccessfully() throws {
        let context = ModelContext(modelContainer)
        let authorID = UUID()
        let author = AuthorEntity(
            id: authorID,
            name: "author",
            imageURL: URL(string: "https://example.com")
        )
        context.insert(author)

        let manga = MangaEntity(
            id: UUID(),
            title: "title",
            createdAt: Date()
        )
        manga.author = author

        #expect(throws: Never.self) {
            try context.save()
        }

        #expect(manga.author?.id == authorID)
        #expect(author.mangasAsAuthor.map(\.id).sorted() == [manga.id])
    }

    @Test func fetchArtistSuccessfully() throws {
        let context = ModelContext(modelContainer)
        let artistID = UUID()
        let artist = AuthorEntity(
            id: artistID,
            name: "artist",
            imageURL: URL(string: "https://example.com")
        )
        context.insert(artist)

        let manga = MangaEntity(
            id: UUID(),
            title: "title",
            createdAt: Date()
        )
        manga.artist = artist
        context.insert(manga)

        #expect(throws: Never.self) {
            try context.save()
        }

        #expect(manga.artist?.id == artistID)
        #expect(artist.mangasAsAritst.map(\.id).sorted() == [manga.id])
    }
}
