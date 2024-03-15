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

    public init() {}
  }

  public enum Action: ViewAction {
    case view(View)

    public enum View {
      case delegate(Delegate)

      public enum Delegate {
        case scrollEndReached
      }
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .view:
        return .none
      }
    }
  }
}
