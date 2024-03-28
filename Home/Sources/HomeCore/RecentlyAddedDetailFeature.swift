//
//  RecentlyAddedDetailFeature.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import Database
import MangaListCore

@Reducer
public struct RecentlyAddedDetailFeature {
  @ObservableState
  public struct State {
    @ObservationStateIgnored var offset: Int = 0
    public var isFetching: Bool = false
    public var mangaList = MangaListFeature.State()
  }

  public enum Action: ViewAction {
    case view(View)
    case initialMangasResponse(IdentifiedArrayOf<Manga>)
    case mangasResponse(IdentifiedArrayOf<Manga>)
    case refresh
    case mangaList(MangaListFeature.Action)
    case fetch

    public enum View {
      case fetchInitialMangas
    }
  }

  @Dependency(\.continuousClock) private var clock
  @Dependency(\.recentlyAddedMangas) private var recentlyAddedMangas

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.fetchInitialMangas):
        return .run { send in
          if let mangas = try? await IdentifiedArray(
            uniqueElements: recentlyAddedMangas.fetchInitialDetail()
          ) {
            await send(.initialMangasResponse(mangas))
          }

          try await clock.sleep(for: .seconds(0.5))
          await send(.refresh)
        }
      case let .initialMangasResponse(mangas):
        state.mangaList.mangas = mangas
        return .none
      case let .mangasResponse(mangas):
        state.isFetching = false
        state.mangaList.mangas = mangas
        state.offset = mangas.count
        return .none
      case .refresh:
        state.isFetching = true
        let currentOffset = state.offset
        let currentMangas = state.mangaList.mangas
        let currentMangaIDs = state.mangaList.mangas.ids

        return .run { send in
          var offset = currentOffset
          var newMangas: IdentifiedArrayOf<Manga> = []

          while true {
            let result = try await recentlyAddedMangas.fetch(
              parameters: FetchRecentlyAddedMangasParameters(limit: 30, offset: offset)
            )

            let mangaIDs = Set(result.map(\.id))
            guard mangaIDs.union(currentMangaIDs).isEmpty else {
              break
            }

            newMangas.append(contentsOf: result)
            offset += 30
          }

          await send(.mangasResponse(newMangas + currentMangas))
        }
      case .fetch:
        state.isFetching = true
        let offset = state.offset
        let currentMangas = state.mangaList.mangas

        return .run { send in
          let newMangas = try await IdentifiedArray(
            uniqueElements: recentlyAddedMangas.fetch(
              parameters: FetchRecentlyAddedMangasParameters(limit: 30, offset: offset)
            )
          )

          if offset == 0 {
            await send(.mangasResponse(newMangas))
          } else {
            await send(.mangasResponse(currentMangas + newMangas))
          }
        }
      case .mangaList(.view(.listEndReached)):
        return .send(.fetch)
      case .mangaList(.view(.refresh)):
        return .send(.refresh)
      case .mangaList:
        return .none
      }
    }

    Scope(state: \.mangaList, action: \.mangaList) {
      MangaListFeature()
    }
  }
}
