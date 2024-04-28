//
//  RecentlyAddedFeature.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import ComposableArchitecture
import Foundation
import MangaList

@Reducer
public struct RecentlyAddedFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var mangaList = MangaListFeature.State()
  }

  public enum Action: Sendable {
    case mangaList(MangaListFeature.Action)
  }

  public var body: some ReducerOf<Self> {
    Scope(state: \.mangaList, action: \.mangaList) {
      MangaListFeature()
    }
  }
}
