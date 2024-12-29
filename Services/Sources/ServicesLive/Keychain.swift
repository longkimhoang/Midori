//
//  Keychain.swift
//  Services
//
//  Created by Long Kim on 29/12/24.
//

import KeychainAccess

extension Keychain {
    /// The shared keychain for personal auth clients.
    nonisolated(unsafe) static let personalAuthClient = Keychain(
        service: "com.longkimhoang.Midori.services.personal-auth-client"
    )
}
