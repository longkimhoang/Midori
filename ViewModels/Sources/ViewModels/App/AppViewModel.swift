//
//  AppViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 8/11/24.
//

import Combine

@MainActor
public final class AppViewModel {
    @Published public var selectedTab: Tab
    public var home = HomeViewModel()
    public var profile = ProfileViewModel()
    public var account = AccountViewModel()

    public init() {
        selectedTab = .home

        account.$personalClient
            .compactMap { $0 }
            .assign(to: &profile.$client)
    }
}
