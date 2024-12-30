//
//  AccountViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Combine
import Dependencies
import Foundation
import MidoriServices
import MidoriStorage

@MainActor
public final class AccountViewModel: ObservableObject {
    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.personalAuthClientService) private var personalAuthClientService
    @Dependency(\.authService) private var authService

    @Published public var authState: AuthState?
    @Published public var personalClient = PersonalClient()
    @Published public var isLoading: Bool = false

    public init() {}

    public nonisolated func savePersonalClient() async {
        await personalAuthClientService.saveClientConfiguration(
            .init(clientID: personalClient.clientID, clientSecret: personalClient.clientSecret)
        )
    }

    public func initializeAuthState() async throws {
        guard let config = await fetchClientConfiguration() else {
            authState = .clientSetupRequired
            return
        }

        personalClient = PersonalClient(config)
        guard let userID = try await authService.initializeSession() else {
            authState = .loggedOut
            return
        }

        try updateAuthState(userID: userID)
    }

    public func signIn(username: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let userID = try await authService.signIn(username: username, password: password)
        try updateAuthState(userID: userID)
    }

    public func signOut() async throws {
        isLoading = true
        defer { isLoading = false }

        try await authService.signOut()
        authState = .loggedOut
    }

    nonisolated func fetchClientConfiguration() async -> PersonalClientConfiguration? {
        await personalAuthClientService.fetchClientConfiguration()
    }

    func updateAuthState(userID: UUID) throws {
        let context = modelContainer.mainContext
        guard let user = try context.fetch(UserEntity.withID(userID)).first.map(User.init) else {
            return
        }

        authState = .loggedIn(user)
    }
}
