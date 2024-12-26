//
//  AuthenticationRequestDecorator.swift
//  MangaDexAuth
//
//  Created by Long Kim on 26/12/24.
//

import Dependencies
import Foundation

public protocol AuthenticationRequestDecorator<AuthenticatorType>: Actor {
    associatedtype AuthenticatorType: Authenticator

    var credential: AuthCredential? { get set }

    func decorate(_ request: inout URLRequest) async throws
    func refreshCredential() async throws
}

actor AuthenticationRequestDecoratorImplementation<AuthenticatorType: Authenticator>: AuthenticationRequestDecorator {
    private var refreshingCredentialTask: Task<Void, Error>?

    public let authenticator: AuthenticatorType
    public var credential: AuthCredential?

    public init(authenticator: AuthenticatorType) {
        self.authenticator = authenticator
    }

    public func decorate(_ request: inout URLRequest) async throws {
        if let credential {
            authenticator.adopt(crendedential: credential, into: &request)
        }
    }

    public func refreshCredential() async throws {
        if let refreshingCredentialTask {
            // There's a pending refresh task, await for its result then return
            try await refreshingCredentialTask.value
            return
        }

        refreshingCredentialTask = Task {
            guard let credential else {
                throw AuthError.missingCredential
            }
            self.credential = try await authenticator.refresh(existing: credential)
        }

        try await refreshingCredentialTask?.value
        refreshingCredentialTask = nil
    }
}

// MARK: - Dependency

private enum AuthenticationRequestDecoratorDependencyKey: DependencyKey {
    static let liveValue: any AuthenticationRequestDecorator = {
        let authenticator = PersonalClientAuthenticator()
        return AuthenticationRequestDecoratorImplementation(authenticator: authenticator)
    }()
}

public extension DependencyValues {
    /// The decorator used to supply authentication information to requests.
    var authenticationRequestDecorator: any AuthenticationRequestDecorator {
        get { self[AuthenticationRequestDecoratorDependencyKey.self] }
        set { self[AuthenticationRequestDecoratorDependencyKey.self] = newValue }
    }
}
