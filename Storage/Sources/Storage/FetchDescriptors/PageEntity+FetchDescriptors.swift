//
//  PageEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 12/11/24.
//

import Foundation
import SwiftData

public extension PageEntity {
    static func withChapterID(_ chapterID: UUID, quality: Quality) -> FetchDescriptor<PageEntity> {
        var descriptor = FetchDescriptor<PageEntity>()
        descriptor.predicate = #Predicate {
            $0.chapter?.id == chapterID && $0.qualityRepresentation == quality.rawValue
        }
        descriptor.sortBy = [.init(\.pageIndex)]

        return descriptor
    }
}
