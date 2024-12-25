//
//  Authenticator.swift
//  MangaDexAuth
//
//  Created by Long Kim on 26/12/24.
//

/// A type that performs authentication for MangaDex API endpoints.
public protocol Authenticator: Sendable {
    /// The type of the options used to sign in.
    ///
    /// This could be username/password, OAuth config etc.
    associatedtype SignInOptions: Sendable = Void

    /// Performs initial sign in.
    /// - Parameter options: The options used to sign in.
    /// - Returns: A credential instance indicating the result.
    func signIn(using options: SignInOptions) async throws -> AuthCredential

    /// Refreshes the provided credential.
    /// - Parameter credential: The credential to refresh.
    /// - Returns: A new, refreshed credential.
    func refresh(existing credential: AuthCredential) async throws -> AuthCredential
}
