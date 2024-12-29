//
//  AuthService+Live.swift
//  Services
//
//  Created by Long Kim on 28/12/24.
//

import Dependencies
import MangaDexAPIClient
import MangaDexAuth
import MidoriServices

extension AuthService: DependencyKey {
    public static let liveValue = AuthService(
        signInWithUsernameAndPassword: { username, password in
            @Dependency(\.modelContainer) var modelContainer
            @Dependency(\.personalClientAuthenticator) var authenticator
            @Dependency(\.authenticationCredentialProvider) var credentialProvider
            @Dependency(\.mangaDexAPIClient) var apiClient
            let userAPIResponseIngestor = UserAPIResponseIngestor(modelContainer: modelContainer)

            let credential = try await authenticator.signIn(using: .init(username: username, password: password))
            credentialProvider.setCredential(credential)
            let request = MangaDexAPI.User.me()
            let user = try await apiClient.send(request).value.data
            try userAPIResponseIngestor.importLoggedInUser(user)
        }
    )
}
