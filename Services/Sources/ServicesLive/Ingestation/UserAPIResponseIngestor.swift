//
//  UserAPIResponseIngestor.swift
//  Services
//
//  Created by Long Kim on 29/12/24.
//

import MangaDexAPIClient
import MidoriStorage
import SwiftData

@ModelActor
actor UserAPIResponseIngestor {
    func importLoggedInUser(_ user: User) throws {
        let userEntity = UserEntity(id: user.id, username: user.username)
        modelContext.insert(userEntity)
        try modelContext.save()
    }
}
