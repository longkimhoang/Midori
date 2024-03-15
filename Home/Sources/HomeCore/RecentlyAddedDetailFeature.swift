//
//  RecentlyAddedDetailFeature.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import Database
import Dependencies
import MangaListCore

@Reducer
public struct RecentlyAddedDetailFeature {
  @ObservableState
  public struct State {
    public var offset: Int = 0
    public var mangaList = MangaListFeature.State()

    public init() {}
  }

  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public enum Action: ViewAction {
    case mangasResponse(IdentifiedArrayOf<Manga>)
    case mangaList(MangaListFeature.Action)
    case view(View)

    public enum View {
      case fetchInitialMangas
    }
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.mangaList, action: \.mangaList) {
      MangaListFeature()
    }

    Reduce { state, action in
      switch action {
      case let .mangasResponse(mangas):
        state.mangaList.mangas.append(contentsOf: mangas)
        state.offset = state.mangaList.mangas.count
        return .none
      case .mangaList(.view(.delegate(.scrollEndReached))):
        return .none
      case .view(.fetchInitialMangas):
        return .run { @MainActor send in
          let mangas = try IdentifiedArray(uniqueElements: recentlyAddedMangas.fetchInitialDetail())
          send(.mangasResponse(mangas))
        }
      }
    }
  }
}
