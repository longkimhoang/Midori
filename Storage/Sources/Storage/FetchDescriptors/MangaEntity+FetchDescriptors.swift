//
//  MangaEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 26/10/24.
//

import Dependencies
import Foundation
import SwiftData

public extension MangaEntity {
    static func popular() -> FetchDescriptor<MangaEntity> {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date.now) var now

        let lastMonth = calendar.date(
            byAdding: .month,
            value: -1,
            to: now,
            wrappingComponents: false
        ) ?? now

        var descriptor = FetchDescriptor.mangaOverview()
        descriptor.predicate = #Predicate {
            isValidManga.evaluate($0) && $0.createdAt >= lastMonth
        }
        descriptor.sortBy = [.init(\.followCount, order: .reverse)]
        descriptor.fetchLimit = 10

        return descriptor
    }

    static func recentlyAdded(limit: Int = 100, offset: Int = 0) -> FetchDescriptor<MangaEntity> {
        var descriptor = FetchDescriptor.mangaOverview()
        descriptor.predicate = #Predicate { isValidManga.evaluate($0) }
        descriptor.sortBy = [.init(\.createdAt, order: .reverse)]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return descriptor
    }

    static func withID(_ id: UUID) -> FetchDescriptor<MangaEntity> {
        var descriptor = FetchDescriptor<MangaEntity>()
        descriptor.predicate = #Predicate {
            isValidManga.evaluate($0) && $0.id == id
        }
        descriptor.fetchLimit = 1
        descriptor.relationshipKeyPathsForPrefetching = [\.author, \.artist, \.currentCover]

        return descriptor
    }

    private static func overview() -> FetchDescriptor<MangaEntity> {
        var descriptor = FetchDescriptor<MangaEntity>()
        descriptor.propertiesToFetch = [\.id, \.title, \.synopsis]
        descriptor.relationshipKeyPathsForPrefetching = [\.author, \.artist, \.currentCover]
        return descriptor
    }

    private static var isValidManga: Expression<MangaEntity, Bool> {
        #Expression { $0.author != nil }
    }
}

private extension FetchDescriptor<MangaEntity> {
    static func mangaOverview() -> Self {
        var descriptor = FetchDescriptor<MangaEntity>()
        descriptor.propertiesToFetch = [\.id, \.title, \.synopsis]
        descriptor.relationshipKeyPathsForPrefetching = [\.author, \.artist]
        return descriptor
    }
}
