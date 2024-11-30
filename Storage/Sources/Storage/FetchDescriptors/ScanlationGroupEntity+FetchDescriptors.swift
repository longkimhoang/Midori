//
//  ScanlationGroupEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 30/11/24.
//

import Foundation
import SwiftData

public extension ScanlationGroupEntity {
    static func withID(_ id: UUID) -> FetchDescriptor<ScanlationGroupEntity> {
        var descriptor = FetchDescriptor<ScanlationGroupEntity>()
        descriptor.predicate = #Predicate {
            $0.id == id
        }
        descriptor.fetchLimit = 1

        return descriptor
    }
}
