//
//  RecentlyAddedFeature.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct RecentlyAddedFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {}

  public enum Action: Sendable {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
