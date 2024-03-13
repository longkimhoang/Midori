//
//  RecentlyAddedDetailFeature.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import Dependencies

@Reducer
public struct RecentlyAddedDetailFeature {
  @ObservableState
  public struct State {
    public init() {}
  }

  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

  public enum Action {}
}
