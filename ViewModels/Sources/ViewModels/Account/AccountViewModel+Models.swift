//
//  AccountViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Foundation

public extension AccountViewModel {
    struct User: Equatable {
        public let id: UUID
        public let username: String
    }

    struct PersonalClientInput: Equatable {
        public var clientID: String = ""
        public var clientSecret: String = ""
    }

    enum AuthState: Equatable {
        case clientSetupRequired
        case loggedOut
        case loggedIn(User)
    }
}
