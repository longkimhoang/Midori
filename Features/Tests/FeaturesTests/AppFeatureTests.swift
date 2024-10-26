//
//  AppFeatureTests.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
@testable import MidoriFeatures
import Testing

@Suite("App reducer")
@MainActor struct AppFeatureTests {
    let store = TestStore(initialState: App.State()) {
        App()
    }

    @Test("initial state")
    func initialState() {
        #expect(store.state.selectedTab == .home)
    }

    @Test("tabSelected action")
    func selectTab() async {
        await store.send(.tabSelected(.search)) {
            $0.selectedTab = .search
        }
    }
}
