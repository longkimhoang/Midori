//
//  PersonalAuthClientService+Live.swift
//  Services
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import Foundation
@preconcurrency import KeychainAccess
import MidoriServices
import Security

extension PersonalAuthClientService: DependencyKey {
    public static let liveValue: Self = PersonalAuthClientService(
        fetchClientConfiguration: {
            guard let data = keychain[data: account] else {
                return nil
            }

            let configuration = try? JSONDecoder().decode(PersonalClientConfiguration.self, from: data)
            if let configuration {
                @Dependency(\.personalClientAuthenticator) var authenticator
                authenticator.configuration.withLock {
                    $0 = .init(clientID: configuration.clientID, clientSecret: configuration.clientSecret)
                }
            }

            return configuration
        },
        saveClientConfiguration: { configuration in
            guard let data = try? JSONEncoder().encode(configuration) else {
                return
            }

            keychain[data: account] = data
            @Dependency(\.personalClientAuthenticator) var authenticator
            authenticator.configuration.withLock {
                $0 = .init(clientID: configuration.clientID, clientSecret: configuration.clientSecret)
            }
        }
    )

    static let account = "PersonalAuthClient"
    static let keychain = Keychain(service: "com.longkimhoang.Midori.services.personal-auth-client")
}
