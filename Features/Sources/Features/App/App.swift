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
        public enum Tab {
            case home, search
        }

        public var selectedTab: Tab = .home
        public var home = Home.State()
    }

    public enum Action {
        case tabSelected(State.Tab)
        case home(Home.Action)
    }

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
