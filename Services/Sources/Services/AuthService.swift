//
//  AuthService.swift
//  Services
//
//  Created by Long Kim on 28/12/24.
//

import Dependencies
import Foundation

public struct AuthService: Sendable {
    public var signInWithUsernameAndPassword: @Sendable (_ username: String, _ password: String) async throws -> UUID
    public var initializeSession: @Sendable () async throws -> UUID?

    public init(
        signInWithUsernameAndPassword: @escaping @Sendable (_ username: String, _ password: String) async throws ->
            UUID,
        initializeSession: @escaping @Sendable () async throws -> UUID?
    ) {
        self.signInWithUsernameAndPassword = signInWithUsernameAndPassword
        self.initializeSession = initializeSession
    }
}

public extension AuthService {
    func signIn(username: String, password: String) async throws -> UUID {
        try await signInWithUsernameAndPassword(username, password)
    }
}

extension AuthService: TestDependencyKey {
    public static let testValue = AuthService(
        signInWithUsernameAndPassword: unimplemented("AuthService.signInWithUsernameAndPassword"),
        initializeSession: unimplemented("AuthService.initializeSession")
    )
}

public extension DependencyValues {
    var authService: AuthService {
        get { self[AuthService.self] }
        set { self[AuthService.self] = newValue }
    }
}
