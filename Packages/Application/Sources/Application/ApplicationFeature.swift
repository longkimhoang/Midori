//
//  ApplicationFeature.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import ComposableArchitecture
import Home

@Reducer
public struct ApplicationFeature {
  @ObservableState
  public struct State: Equatable {
    public var selectedTab: Tab = .home
    public var home = HomeFeature.State()

    public init() {}
  }

  public enum Action {
    case selectTab(Tab)
    case home(HomeFeature.Action)
  }

  public enum Tab {
    case home
    case search
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.home, action: \.home) {
      HomeFeature()
    }

    Reduce { state, action in
      switch action {
      case let .selectTab(tab):
        state.selectedTab = tab
        return .none
      case .home:
        return .none
      }
    }
  }
}
