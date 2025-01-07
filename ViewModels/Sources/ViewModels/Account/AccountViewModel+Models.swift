//
//  AccountViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Foundation
import MidoriServices
import MidoriStorage

extension AccountViewModel {
    public struct User: Equatable, Sendable {
        public let id: UUID
        public let username: String
    }

    public struct PersonalClient: Equatable, Sendable {
        public var clientID: String = ""
        public var clientSecret: String = ""
    }

    public enum AuthState: Equatable, Sendable {
        case clientSetupRequired
        case loggedOut
        case loggedIn(User)
    }
}

extension AccountViewModel.User {
    init(_ entity: UserEntity) {
        self.init(id: entity.id, username: entity.username)
    }
}

extension AccountViewModel.PersonalClient {
    init(_ configuration: PersonalClientConfiguration) {
        self.init(clientID: configuration.clientID, clientSecret: configuration.clientSecret)
    }
}
