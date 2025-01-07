//
//  ChapterService.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import Foundation

public struct ChapterService: Sendable {
    public var syncLatestChapters: @Sendable () async throws -> Void
    public var syncChapterPages: @Sendable (_ chapterID: UUID) async throws -> Void

    public init(
        syncLatestChapters: @Sendable @escaping () async throws -> Void,
        syncChapterPages: @Sendable @escaping (UUID) async throws -> Void
    ) {
        self.syncLatestChapters = syncLatestChapters
        self.syncChapterPages = syncChapterPages
    }
}

extension ChapterService {
    public func syncChapterPages(for chapterID: UUID) async throws {
        try await syncChapterPages(chapterID)
    }
}

extension ChapterService: TestDependencyKey {
    public static let testValue = Self(
        syncLatestChapters: unimplemented("ChapterService.syncLatestChapters"),
        syncChapterPages: unimplemented("ChapterService.syncChapterPages")
    )
}

extension DependencyValues {
    public var chapterService: ChapterService {
        get { self[ChapterService.self] }
        set { self[ChapterService.self] = newValue }
    }
}
