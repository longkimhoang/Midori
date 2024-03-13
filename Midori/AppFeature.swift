//
//  AppFeature.swift
//  Midori
//
//  Created by Long Kim on 10/3/24.
//

import ComposableArchitecture
import HomeCore

@Reducer
struct AppFeature {
  struct State {
    var home = HomeFeature.State()
  }

  enum Action {
    case home(HomeFeature.Action)
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.home, action: \.home) {
      HomeFeature()
    }
  }
}
