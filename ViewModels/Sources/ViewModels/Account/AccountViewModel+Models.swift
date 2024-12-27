//
//  AccountViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Foundation
import MidoriServices

public extension AccountViewModel {
    struct User: Equatable, Sendable {
        public let id: UUID
        public let username: String
    }

    struct PersonalClientInput: Equatable, Sendable {
        public var clientID: String = ""
        public var clientSecret: String = ""
    }

    enum AuthState: Equatable, Sendable {
        case clientSetupRequired
        case loggedOut
        case loggedIn(User)
    }
}

public extension AccountViewModel.PersonalClientInput {
    init(_ configuration: PersonalClientConfiguration) {
        self.init(clientID: configuration.clientID, clientSecret: configuration.clientSecret)
    }
}
