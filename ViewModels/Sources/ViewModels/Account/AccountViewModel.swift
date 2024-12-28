//
//  AccountViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Combine
import Dependencies
import Foundation

@MainActor
public final class AccountViewModel: ObservableObject {
    @Dependency(\.personalAuthClientService) private var personalAuthClientService

    @Published public var authState: AuthState?
    @Published public var personalClient = PersonalClient()

    public init() {}

    public nonisolated func savePersonalClient() async {
        await personalAuthClientService.saveClientConfiguration(
            .init(clientID: personalClient.clientID, clientSecret: personalClient.clientSecret)
        )
    }

    public nonisolated func loadClientDetails() async {
        guard let config = await personalAuthClientService.fetchClientConfiguration() else {
            await MainActor.run {
                authState = .clientSetupRequired
            }
            return
        }

        await MainActor.run {
            personalClient = PersonalClient(config)
            authState = .loggedOut
        }
    }
}
