//
//  ChapterEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 28/10/24.
//

import Foundation
import SwiftData

extension ChapterEntity {
    public static func latest(limit: Int = 100, offset: Int = 0) -> FetchDescriptor<ChapterEntity> {
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

    public static func feed(for mangaID: UUID, limit: Int = 100, offset: Int = 0) -> FetchDescriptor<ChapterEntity> {
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

    public static func withID(_ id: UUID) -> FetchDescriptor<ChapterEntity> {
        var descriptor = FetchDescriptor<ChapterEntity>()
        descriptor.predicate = #Predicate {
            $0.manga != nil && $0.id == id
        }
        descriptor.fetchLimit = 1

        return descriptor
    }

    public static func followedFeed(limit: Int = 100, offset: Int = 0) -> FetchDescriptor<ChapterEntity> {
        var descriptor = FetchDescriptor<ChapterEntity>()
        descriptor.predicate = #Predicate {
            $0.manga?.followed == true
        }
        descriptor.sortBy = [
            .init(\.readableAt, order: .reverse),
        ]
        descriptor.relationshipKeyPathsForPrefetching = [\.scanlationGroup, \.manga]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return descriptor
    }
}
