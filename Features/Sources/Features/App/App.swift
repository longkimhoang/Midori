//
//  App.swift
//  Features
//
//  Created by Long Kim on 26/10/24.
//

import ComposableArchitecture

@Reducer
public struct App {
    @ObservableState
    public struct State: Equatable {
        public enum Tab: String {
            case home, search
        }

        public var selectedTab: Tab
        public var home: Home.State

        public init(selectedTab: Tab = .home, home: Home.State = .init()) {
            self.selectedTab = selectedTab
            self.home = home
        }
    }

    public enum Action {
        case tabSelected(State.Tab)
        case home(Home.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            Home()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            case .home:
                return .none
            }
        }
    }
}
