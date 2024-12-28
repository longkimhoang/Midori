//
//  AuthService+Live.swift
//  Services
//
//  Created by Long Kim on 28/12/24.
//

import Dependencies
import MangaDexAuth
import MidoriServices

extension AuthService: DependencyKey {
    public static let liveValue = AuthService(
        signInWithUsernameAndPassword: { username, password in
            @Dependency(\.personalClientAuthenticator) var authenticator
            @Dependency(\.authenticationCredentialProvider) var credentialProvider
            let credential = try await authenticator.signIn(using: .init(username: username, password: password))
            credentialProvider.setCredential(credential)
        }
    )
}
