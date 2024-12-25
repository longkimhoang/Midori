//
//  AuthCredential.swift
//  MangaDexAuth
//
//  Created by Long Kim on 25/12/24.
//

/// The credential returned from MangaDex authentication endpoints.
public struct AuthCredential: Codable, Sendable {
    /// The access token.
    public let accessToken: String
    /// The refresh token. Might be `nil` if the endpoint doesn't return one.
    public let refreshToken: String

    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
