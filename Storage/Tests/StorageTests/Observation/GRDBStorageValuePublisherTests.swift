//
//  GRDBStorageValuePublisherTests.swift
//  Storage
//
//  Created by Long Kim on 23/10/24.
//

import Dependencies
import Foundation
@testable import Storage
import Testing

@Suite("GRDBStorageValuePublisher")
struct GRDBStorageValuePublisherTests {
    @Dependency(\.persistenceContainer) var persistenceContainer

    @Test("Receives value")
    func receivesValue() async throws {
        try await withMainSerialExecutor {
            let id = UUID()
            let record = MangaEntity(
                id: id,
                title: "title",
                createdAt: Date()
            )

            try await persistenceContainer.dbWriter.write { db in
                try record.save(db)
            }

            let publisher = GRDBStorageValuePublisher { db in
                try MangaEntity.fetchOne(db, id: id)
            }

            try await confirmation("Received value") { received in
                for try await value in publisher.first().values {
                    let manga = try #require(value)
                    #expect(manga.id == id)

                    received()
                }
            }
        }
    }

    @Test("Receives value immediately on main thread")
    @MainActor func receivesValueImmediately() async throws {
        let id = UUID()
        let record = MangaEntity(
            id: id,
            title: "title",
            createdAt: Date()
        )

        try await persistenceContainer.dbWriter.write { db in
            try record.save(db)
        }

        let publisher = GRDBStorageValuePublisher { db in
            try MangaEntity.fetchOne(db, id: id)
        }.receivesFirstValueImmediately()

        try await confirmation("Received value") { received in
            for try await value in publisher.first().values {
                let manga = try #require(value)
                #expect(manga.id == id)

                received()
            }
        }
    }

    @Test("Receives updated value")
    func receivesUpdates() async throws {
        try await withMainSerialExecutor {
            let id = UUID()
            let record = MangaEntity(
                id: id,
                title: "title",
                createdAt: Date()
            )

            let publisher = GRDBStorageValuePublisher { db in
                try MangaEntity.fetchOne(db, id: id)
            }

            let task = Task {
                try await confirmation("Received value updates", expectedCount: 2) { received in
                    let titles = ["title", "updatedTitle"].publisher.setFailureType(to: Error.self)

                    for try await (value, title) in publisher.zip(titles).prefix(2).values {
                        let manga = try #require(value)
                        #expect(manga.id == id)
                        #expect(manga.title == title)

                        received()
                    }
                }
            }

            let updatedRecord = MangaEntity(
                id: id,
                title: "updatedTitle",
                createdAt: Date()
            )

            try await persistenceContainer.dbWriter.write { db in
                try record.save(db)
            }

            try await persistenceContainer.dbWriter.write { db in
                try updatedRecord.upsert(db)
            }

            try await task.value
        }
    }
}
