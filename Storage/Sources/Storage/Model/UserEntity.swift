//
//  UserEntity.swift
//  Storage
//
//  Created by Long Kim on 29/12/24.
//

import Foundation
import SwiftData

@Model
public final class UserEntity {
    #Unique<UserEntity>([\.id])

    public var id: UUID
    public var username: String

    public init(id: UUID, username: String) {
        self.id = id
        self.username = username
    }
}
