//
//  HomeFeature.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import ComposableArchitecture

@Reducer
public struct HomeFeature {
  @ObservableState
  public struct State: Equatable {
    public var path = StackState<Path.State>()
  }

  public enum Action {
    case fetchHomeData
    case path(StackActionOf<Path>)
  }

  @Reducer
  public enum Path {
    case recentlyAdded
    case manga
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
      .forEach(\.path, action: \.path)
  }
}
