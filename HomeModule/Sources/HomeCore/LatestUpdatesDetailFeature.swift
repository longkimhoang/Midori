//
//  LatestUpdatesDetailFeature.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture

@Reducer
public struct LatestUpdatesDetailFeature {
  @ObservableState
  public struct State {
    public init() {}
  }

  public enum Action: ViewAction {
    case view(View)

    public enum View {
      case fetchLatestChapters
    }
  }

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .view(.fetchLatestChapters):
        return .none
      }
    }
  }
}
