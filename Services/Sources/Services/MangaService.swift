//
//  MangaService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import Foundation

public enum MangaServiceError: Error {
    case mangaNotFound
}

public struct MangaService: Sendable {
    public var syncPopularMangas: @Sendable () async throws -> Void
    public var syncRecentlyAddedMangas: @Sendable (_ limit: Int, _ offset: Int) async throws -> Void
    public var syncMangaWithID: @Sendable (_ id: UUID) async throws -> Void
    public var syncMangaFeed: @Sendable (_ id: UUID, _ limit: Int, _ offset: Int) async throws -> Void
    public var syncMangaAggregate: @Sendable (_ mangaID: UUID, _ scanlationGroupID: UUID) async throws -> Void

    public init(
        syncPopularMangas: @Sendable @escaping () async throws -> Void,
        syncRecentlyAddedMangas: @Sendable @escaping (_ limit: Int, _ offset: Int) async throws -> Void,
        syncMangaWithID: @Sendable @escaping (_ id: UUID) async throws -> Void,
        syncMangaFeed: @Sendable @escaping (_ id: UUID, _ limit: Int, _ offset: Int) async throws -> Void,
        syncMangaAggregate: @Sendable @escaping (_ mangaID: UUID, _ scanlationGroupID: UUID) async throws -> Void
    ) {
        self.syncPopularMangas = syncPopularMangas
        self.syncRecentlyAddedMangas = syncRecentlyAddedMangas
        self.syncMangaWithID = syncMangaWithID
        self.syncMangaFeed = syncMangaFeed
        self.syncMangaAggregate = syncMangaAggregate
    }
}

public extension MangaService {
    func syncManga(id: UUID) async throws {
        try await syncMangaWithID(id)
    }

    func syncRecentlyAddedMangas(limit: Int, offset: Int = 0) async throws {
        try await syncRecentlyAddedMangas(limit, offset)
    }

    func syncMangaFeed(id: UUID, limit: Int, offset: Int = 0) async throws {
        try await syncMangaFeed(id, limit, offset)
    }

    func syncMangaAggregate(mangaID: UUID, scanlationGroupID: UUID) async throws {
        try await syncMangaAggregate(mangaID, scanlationGroupID)
    }
}

extension MangaService: TestDependencyKey {
    public static let testValue = MangaService(
        syncPopularMangas: unimplemented("MangaService.syncPopularMangas"),
        syncRecentlyAddedMangas: unimplemented("MangaService.syncRecentlyAddedMangas"),
        syncMangaWithID: unimplemented("MangaService.syncMangaWithID"),
        syncMangaFeed: unimplemented("MangaService.syncMangaFeed"),
        syncMangaAggregate: unimplemented("MangaService.syncMangaAggregate")
    )
}

public extension DependencyValues {
    var mangaService: MangaService {
        get { self[MangaService.self] }
        set { self[MangaService.self] = newValue }
    }
}
