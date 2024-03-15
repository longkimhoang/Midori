//
//  MangaListFeature.swift
//
//
//  Created by Long Kim on 14/3/24.
//

import ComposableArchitecture
import Database

@Reducer
public struct MangaListFeature {
  @ObservableState
  public struct State {
    public var mangas: IdentifiedArrayOf<Manga> = []
    public var layout: Layout = .list

    public init() {}

    public enum Layout: CaseIterable {
      case list
      case grid
    }
  }

  public enum Action: ViewAction {
    case view(View)

    @CasePathable
    public enum View {
      case delegate(Delegate)
      case layoutChanged(State.Layout)

      public enum Delegate {
        case scrollEndReached
      }
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(.layoutChanged(layout)):
        state.layout = layout
        return .none
      case .view:
        return .none
      }
    }
  }
}
