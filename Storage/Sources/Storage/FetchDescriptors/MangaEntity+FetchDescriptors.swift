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

        let predicate = #Predicate<MangaEntity> {
            $0.createdAt >= lastMonth
        }

        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.followCount, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        descriptor.propertiesToFetch = [\.id, \.title, \.synopsis]
        descriptor.relationshipKeyPathsForPrefetching = []

        return descriptor
    }
}
