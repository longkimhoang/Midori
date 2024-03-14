//
//  RecentlyAddedDetailFeature.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import Database
import Dependencies
import IdentifiedCollections

@Reducer
public struct RecentlyAddedDetailFeature {
  @ObservableState
  public struct State {
    public var mangas: IdentifiedArrayOf<Manga> = []

    public init() {}
  }

  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public enum Action {}
}
