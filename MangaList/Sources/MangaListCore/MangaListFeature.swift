//
//  MangaListFeature.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import Database

@Reducer
public struct MangaListFeature {
  @ObservableState
  public struct State {
    public var layout: MangaListLayout = .list
    public var mangas: IdentifiedArrayOf<Manga> = []

    public init() {}
  }

  public enum Action: ViewAction {
    case changeLayout(MangaListLayout)
    case view(View)

    public enum View {
      case listEndReached
      case refresh
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .changeLayout(layout):
        state.layout = layout
        return .none
      case .view:
        return .none
      }
    }
  }
}

public enum MangaListLayout: Int, CaseIterable {
  case list
  case grid
}
