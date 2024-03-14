//
//  LatestUpdatesDetailFeature.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import Database

@Reducer
public struct LatestUpdatesDetailFeature {
  @ObservableState
  public struct State {
    public var chapters: IdentifiedArrayOf<Chapter> = []

    public init() {}
  }

  public enum Action: ViewAction {
    case chaptersResponse(IdentifiedArrayOf<Chapter>)
    case view(View)

    public enum View {
      case fetchInitialChapters
      case fetchLatestChapters(offset: Int? = nil)
    }
  }

  @Dependency(\.latestChapters) var latestChapters

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .chaptersResponse(chapters):
        state.chapters.append(contentsOf: chapters)
        return .none
      case .view(.fetchInitialChapters):
        return .run { @MainActor send in
          let chapters = try IdentifiedArray(uniqueElements: latestChapters.fetchInitialDetail())
          send(.chaptersResponse(chapters))
        }
      case .view(.fetchLatestChapters):
        return .none
      }
    }
  }
}
