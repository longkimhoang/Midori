//
//  ApplicationFeature.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import ComposableArchitecture

@Reducer
public struct ApplicationFeature {
  @ObservableState
  public struct State: Equatable {
    public var selectedTab: Tab = .home

    public init() {}
  }

  public enum Action {
    case selectTab(Tab)
  }

  public enum Tab {
    case home
    case search
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .selectTab(tab):
        state.selectedTab = tab
        return .none
      }
    }
  }
}
