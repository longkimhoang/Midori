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
    }

    public enum Action {
        case tabSelected(State.Tab)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
