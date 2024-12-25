//
//  PersonalClientAuthenticator.swift
//  MangaDexAuth
//
//  Created by Long Kim on 26/12/24.
//

import Foundation
import os.lock

public enum PersonalClientAuthenticationError: Error {
    case invalidConfiguration
    case invalidResponse
}

public struct PersonalClientAuthenticator: Authenticator {
    public struct Configuration: Sendable {
        public let clientId: String
        public let clientSecret: String
    }

    public struct SignInOptions: Sendable {
        public let username: String
        public let password: String

        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    let session = URLSession(configuration: .ephemeral)

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// The client's configuration.
    ///
    /// This might be initially empty if user has not configured it, since personal clients require setup from the user
    /// side.
    /// - Note: When not configured, all operations will simply fail.
    public let configuration: OSAllocatedUnfairLock<Configuration?>

    public init(configuration: Configuration? = nil) {
        self.configuration = OSAllocatedUnfairLock(initialState: configuration)
    }

    public func signIn(using options: SignInOptions) async throws -> AuthCredential {
        var request = URLRequest(url: baseURL)
        let body = try withCheckedConfiguration { configuration in
            """
            grant_type=password
            username=\(options.username)
            password=\(options.password)
            client_id=\(configuration.clientId)
            client_secret=\(configuration.clientSecret)
            """
        }

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(body.utf8)

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PersonalClientAuthenticationError.invalidResponse
        }

        return try decoder.decode(AuthCredential.self, from: data)
    }

    public func refresh(existing credential: AuthCredential) async throws -> AuthCredential {
        var request = URLRequest(url: baseURL)
        let body = try withCheckedConfiguration { configuration in
            """
            grant_type=refresh_token
            refresh_token=\(credential.refreshToken)
            client_id=\(configuration.clientId)
            client_secret=\(configuration.clientSecret)
            """
        }

        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data(body.utf8)

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PersonalClientAuthenticationError.invalidResponse
        }

        return try decoder.decode(AuthCredential.self, from: data)
    }

    var baseURL: URL {
        URL(string: "https://auth.mangadex.org/realms/mangadex/protocol/openid-connect/token")!
    }

    func withCheckedConfiguration<R>(_ body: @Sendable (Configuration) throws -> R) throws -> R {
        guard let configuration = configuration.withLock({ $0 }) else {
            throw PersonalClientAuthenticationError.invalidConfiguration
        }
        return try body(configuration)
    }
}
