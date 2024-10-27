//
//  MangaService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct MangaService: Sendable {
    public var syncPopularMangas: @Sendable () async throws -> Void
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
