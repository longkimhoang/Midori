//
//  ChapterEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 28/10/24.
//

import Foundation
import SwiftData

public extension ChapterEntity {
    static func latest(limit: Int = 100, offset: Int = 0) -> FetchDescriptor<ChapterEntity> {
        var descriptor = FetchDescriptor<ChapterEntity>()
        descriptor.predicate = #Predicate {
            $0.manga != nil
        }
        descriptor.sortBy = [.init(\.readableAt, order: .reverse)]
        descriptor.relationshipKeyPathsForPrefetching = [\.scanlationGroup, \.manga]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return descriptor
    }

    static func feed(for mangaID: UUID, limit: Int = 100, offset: Int = 0) -> FetchDescriptor<ChapterEntity> {
        var descriptor = FetchDescriptor<ChapterEntity>()
        descriptor.predicate = #Predicate {
            $0.manga?.id == mangaID
        }
        descriptor.sortBy = [
            .init(\.volume, order: .reverse),
            .init(\.chapter, order: .reverse),
            .init(\.readableAt, order: .reverse),
        ]
        descriptor.relationshipKeyPathsForPrefetching = [\.scanlationGroup]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return descriptor
    }
}
