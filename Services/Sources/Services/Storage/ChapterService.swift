//
//  ChapterService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies

public struct ChapterService: Sendable {
    public var syncLatestChapters: @Sendable () async throws -> Void

    public init(syncLatestChapters: @Sendable @escaping () async throws -> Void) {
        self.syncLatestChapters = syncLatestChapters
    }
}

extension ChapterService: TestDependencyKey {
    public static let testValue = Self(
        syncLatestChapters: unimplemented("ChapterService.syncLatestChapters")
    )
}

public extension DependencyValues {
    var chapterService: ChapterService {
        get { self[ChapterService.self] }
        set { self[ChapterService.self] = newValue }
    }
}
