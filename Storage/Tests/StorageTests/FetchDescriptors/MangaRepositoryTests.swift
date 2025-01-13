//
//  MangaRepositoryTests.swift
//  Storage
//
//  Created by Long Kim on 23/10/24.
//

import Dependencies
import Foundation
import SwiftData
import Testing

@testable import MidoriStorage

@Suite("Manga fetch descriptors")
struct MangaFetchDescriptorsTests {
    @Dependency(\.modelContainer) var modelContainer

    @Test func fetchPopularMangas() throws {
        let context = ModelContext(modelContainer)

        let mangaIDs = [UUID(), UUID()]
        let authorID = UUID()
        let artistID = UUID()

        let author = AuthorEntity(id: authorID, name: "author")
        context.insert(author)

        let artist = AuthorEntity(id: artistID, name: "artist")
        context.insert(artist)

        let mangas = [
            MangaEntity(
                id: mangaIDs[0],
                title: "title",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                alternateTitles: [
                    .init(localizedVariants: ["en": "alternate title"]),
                    .init(localizedVariants: ["ja-ro": "こんにちは"]),
                ].compactMap { $0 },
                followCount: 1000
            ),
            MangaEntity(
                id: mangaIDs[1],
                title: "title2",
                createdAt: Date(timeIntervalSinceReferenceDate: 2000),
                followCount: 400
            ),
            MangaEntity(
                id: UUID(),
                title: "title3",
                // slightly over 1 month
                createdAt: Date(timeIntervalSinceReferenceDate: -2_668_410)
            ),
        ]

        for (index, manga) in mangas.enumerated() {
            if index == 1 {
                manga.author = author
            } else {
                manga.author = author
                manga.artist = artist
            }

            let chapter = ChapterEntity(id: UUID(), readableAt: Date())
            manga.chapters.append(chapter)

            context.insert(manga)
        }

        try context.save()

        let result = try withDependencies {
            $0.calendar = Calendar(identifier: .gregorian)
            $0.date = .constant(Date(timeIntervalSinceReferenceDate: 10000))
        } operation: {
            try context.fetch(MangaEntity.popular())
        }

        #expect(result.count == 2)
        #expect(result.map(\.id) == Array(mangaIDs[0 ..< 2]))
    }
}
