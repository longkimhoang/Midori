//
//  AppFeature.swift
//  Midori
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import HomeCore

@Reducer
struct AppFeature {
  @ObservableState
  struct State {
    var home = HomeFeature.State()
    var destination: AppDestination = .home
  }

  enum Action {
    case home(HomeFeature.Action)
    case setDestination(AppDestination)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .setDestination(destination):
        state.destination = destination
        return .none
      case .home:
        return .none
      }
    }

    Scope(state: \.home, action: \.home) {
      HomeFeature()
    }
  }
}
