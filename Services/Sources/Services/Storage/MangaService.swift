//
//  MangaService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import DependenciesMacros
import Foundation

public enum MangaServiceError: Error {
    case mangaNotFound
}

@DependencyClient
public struct MangaService: Sendable {
    public var syncPopularMangas: @Sendable () async throws -> Void
    public var syncRecentlyAddedMangas: @Sendable (_ limit: Int, _ offset: Int) async throws -> Void
    @DependencyEndpoint(method: "syncManga")
    public var syncMangaWithID: @Sendable (_ id: UUID) async throws -> Void
}

extension MangaService: TestDependencyKey {
    public static let testValue = Self()
}

public extension DependencyValues {
    var mangaService: MangaService {
        get { self[MangaService.self] }
        set { self[MangaService.self] = newValue }
    }
}
