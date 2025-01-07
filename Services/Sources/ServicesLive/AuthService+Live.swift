//
//  AuthService+Live.swift
//  Services
//
//  Created by Long Kim on 28/12/24.
//

import Dependencies
import Foundation
import KeychainAccess
import MangaDexAPIClient
import MangaDexAuth
import MidoriServices

extension AuthService: DependencyKey {
    public static let liveValue: AuthService = {
        @Dependency(\.modelContainer) var modelContainer
        @Dependency(\.personalClientAuthenticator) var authenticator
        @Dependency(\.authenticationCredentialProvider) var credentialProvider
        @Dependency(\.mangaDexAPIClient) var apiClient

        return AuthService(
            signInWithUsernameAndPassword: { username, password in
                let userAPIResponseIngestor = UserAPIResponseIngestor(modelContainer: modelContainer)

                let credential = try await authenticator.signIn(using: .init(username: username, password: password))
                credentialProvider.setCredential(credential)
                let request = MangaDexAPI.User.me()
                let user = try await apiClient.send(request).value.data
                try userAPIResponseIngestor.importLoggedInUser(user)

                keychain[data: username] = try JSONEncoder().encode(credential)
                UserDefaults.standard.set(username, forKey: usernameDefaultsKey)

                return user.id
            },
            initializeSession: {
                guard let username = UserDefaults.standard.string(forKey: usernameDefaultsKey),
                    let data = keychain[data: username],
                    let credential = try? JSONDecoder().decode(AuthCredential.self, from: data)
                else {
                    return nil
                }

                let userAPIResponseIngestor = UserAPIResponseIngestor(modelContainer: modelContainer)
                do {
                    let refreshedCreditential = try await authenticator.refresh(existing: credential)
                    credentialProvider.setCredential(refreshedCreditential)
                    let request = MangaDexAPI.User.me()
                    let user = try await apiClient.send(request).value.data
                    try userAPIResponseIngestor.importLoggedInUser(user)

                    keychain[data: username] = try JSONEncoder().encode(credential)
                    return user.id
                } catch {
                    return nil
                }
            },
            signOut: {
                guard let username = UserDefaults.standard.string(forKey: usernameDefaultsKey),
                    let data = keychain[data: username],
                    let credential = try? JSONDecoder().decode(AuthCredential.self, from: data)
                else {
                    return
                }
                try await authenticator.signOut(revoking: credential)
                keychain[data: username] = nil
                UserDefaults.standard.removeObject(forKey: usernameDefaultsKey)
            }
        )
    }()

    static let usernameDefaultsKey = "com.longkimhoang.Midori.services.personal-auth-client.username"
    nonisolated(unsafe) static let keychain = Keychain.personalAuthClient
}
