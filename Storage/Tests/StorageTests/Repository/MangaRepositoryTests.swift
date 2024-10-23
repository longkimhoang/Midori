//
//  MangaRepositoryTests.swift
//  Storage
//
//  Created by Long Kim on 23/10/24.
//

import Dependencies
import Foundation
import GRDB
import MidoriModels
@testable import Storage
import Testing

struct Test: Codable, FetchableRecord {
    struct PartialAuthor: Codable {
        let name: String
    }

    let manga: Manga
    let author: PartialAuthor
    let artist: PartialAuthor?
}

@Suite("MangaRepository")
struct MangaRepositoryTests {
    @Dependency(\.persistenceContainer.dbWriter) var dbWriter
    let repository = MangaRepository.liveValue

    @Test func fetchPopularMangas() async throws {
        let id = UUID()
        let record = Manga(
            id: id,
            title: "title",
            createdAt: Date(timeIntervalSinceReferenceDate: 2000)
        )

        try await dbWriter.write { db in
            try record.save(db)
        }

        try await confirmation("Fetched popular mangas") { fetched in
            try await withDependencies {
                $0.calendar = Calendar(identifier: .gregorian)
                $0.date = .constant(Date(timeIntervalSinceReferenceDate: 1000))
            } operation: {
                for try await result in repository.fetchPopularMangas().first().values {
                    fetched()
                }
            }
        }
    }
}
