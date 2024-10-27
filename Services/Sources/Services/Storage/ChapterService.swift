//
//  ChapterService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import DependenciesMacros

@DependencyClient
public struct ChapterService: Sendable {
    public var syncLatestChapters: @Sendable () async throws -> Void
}

extension ChapterService: TestDependencyKey {
    public static let testValue = Self()
}

public extension DependencyValues {
    var chapterService: ChapterService {
        get { self[ChapterService.self] }
        set { self[ChapterService.self] = newValue }
    }
}
