//
//  PersonalClientAuthenticator.swift
//  MangaDexAuth
//
//  Created by Long Kim on 26/12/24.
//

import Foundation
import Get
import os.lock

public struct PersonalClientAuthenticator: Authenticator {
    public typealias Configuration = PersonalClientConfiguration

    public struct SignInOptions: Sendable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    let apiClient: APIClient

    /// The client's configuration.
    ///
    /// This might be initially empty if user has not configured it, since personal clients require setup from the user
    /// side.
    /// - Note: When not configured, all operations will simply fail.
    public let configuration: OSAllocatedUnfairLock<Configuration?>

    public init(configuration: Configuration? = nil) {
        self.configuration = OSAllocatedUnfairLock(initialState: configuration)
        apiClient = APIClient(
            baseURL: URL(string: "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token")
        ) {
            $0.sessionConfiguration = .ephemeral
            $0.decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
    }

    public func signIn(using options: SignInOptions) async throws -> AuthCredential {
        let body = try withCheckedConfiguration { configuration in
            """
            grant_type=password
            username=\(options.username)
            password=\(options.password)
            client_id=\(configuration.clientID)
            client_secret=\(configuration.clientSecret)
            """
        }

        let request = Request<AuthCredential>(
            path: "/",
            method: .post,
            body: body,
            headers: ["Content-Type": "application/x-www-form-urlencoded"]
        )

        return try await apiClient.send(request).value
    }

    public func adopt(crendedential: AuthCredential, into request: inout URLRequest) {
        request.setValue("Bearer \(crendedential.accessToken)", forHTTPHeaderField: "Authorization")
    }

    public func refresh(existing credential: AuthCredential) async throws -> AuthCredential {
        let body = try withCheckedConfiguration { configuration in
            """
            grant_type=refresh_token
            refresh_token=\(credential.refreshToken)
            client_id=\(configuration.clientID)
            client_secret=\(configuration.clientSecret)
            """
        }

        let request = Request<AuthCredential>(
            path: "/",
            method: .post,
            body: body,
            headers: ["Content-Type": "application/x-www-form-urlencoded"]
        )

        return try await apiClient.send(request).value
    }

    func withCheckedConfiguration<R>(_ body: @Sendable (Configuration) throws -> R) throws -> R {
        guard let configuration = configuration.withLock({ $0 }) else {
            throw AuthError.invalidConfiguration
        }
        return try body(configuration)
    }
}
