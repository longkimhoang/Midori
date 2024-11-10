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

    public init() {
        selectedTab = .home
    }
}
