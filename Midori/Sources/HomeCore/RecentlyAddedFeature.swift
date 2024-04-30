//
//  RecentlyAddedFeature.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import ComposableArchitecture
import Domain
import Foundation
import MangaListCore

@Reducer
public struct RecentlyAddedFeature: Sendable {
  public typealias Manga = MangaListCore.Manga

  @ObservableState
  public struct State: Equatable, Sendable {
    public var mangaList = MangaListFeature.State()
  }

  public enum Action: Sendable {
    case fetchMangas
    case mangasResponse(Result<IdentifiedArrayOf<Manga>, any Error>, initial: Bool)
    case mangaList(MangaListFeature.Action)
  }

  @Dependency(\.recentlyAddedData) private var recentlyAddedData

  public var body: some ReducerOf<Self> {
    Scope(state: \.mangaList, action: \.mangaList) {
      MangaListFeature()
    }

    Reduce { state, action in
      switch action {
      case .fetchMangas:
        return .run { send in
          let initialMangas = try await recentlyAddedData.fetchRecentMangasFromStorage()
          await send(.mangasResponse(.success(initialMangas), initial: true))
        }
      case let .mangasResponse(.success(mangas), initial: true):
        state.mangaList.mangas = mangas
        return .none
      case let .mangasResponse(.success(mangas), initial: false):
        state.mangaList.mangas.append(contentsOf: mangas)
        return .none
      case .mangasResponse(.failure, _):
        return .none
      case .mangaList:
        return .none
      }
    }
  }
}
