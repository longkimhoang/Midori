//
//  Authenticator.swift
//  MangaDexAuth
//
//  Created by Long Kim on 26/12/24.
//

import Foundation

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

    /// Adopts the credential into the provided request.
    /// - Parameters:
    ///   - crendedential: The credential to adopt.
    ///   - request: An `URLRequest` instance to transform.
    func adopt(crendedential: AuthCredential, into request: inout URLRequest)

    /// Refreshes the provided credential.
    /// - Parameter credential: The credential to refresh.
    /// - Returns: A new, refreshed credential.
    func refresh(existing credential: AuthCredential) async throws -> AuthCredential

    /// Performs sign out.
    ///
    /// - Parameter credential: The current credential.
    func signOut(revoking credential: AuthCredential) async throws
}
