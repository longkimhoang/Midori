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
    public var mangaList = MangaListFeature.State()

    public init() {}
  }

  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public enum Action {
    case mangaList(MangaListFeature.Action)
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.mangaList, action: \.mangaList) {
      MangaListFeature()
    }
  }
}
