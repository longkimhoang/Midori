//
//  UserEntity+FetchDescriptors.swift
//  Storage
//
//  Created by Long Kim on 29/12/24.
//

import Foundation
import SwiftData

public extension UserEntity {
    static func withID(_ id: UUID) -> FetchDescriptor<UserEntity> {
        var descriptor = FetchDescriptor<UserEntity>()
        descriptor.predicate = #Predicate {
            $0.id == id
        }
        descriptor.fetchLimit = 1

        return descriptor
    }
}
