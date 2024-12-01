//
//  MangaAggregateEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 1/12/24.
//

import Foundation
import SwiftData

public extension MangaAggregateEntity {
    static func withMangaID(_ mangaID: UUID, scanlationGroupID: UUID) -> FetchDescriptor<MangaAggregateEntity> {
        var descriptor = FetchDescriptor<MangaAggregateEntity>()
        descriptor.predicate = #Predicate {
            $0.manga?.id == mangaID && $0.scanlationGroup?.id == scanlationGroupID
        }
        descriptor.fetchLimit = 1
        return descriptor
    }
}
