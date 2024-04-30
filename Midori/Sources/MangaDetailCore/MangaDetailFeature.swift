//
//  MangaDetailFeature.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct MangaDetailFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    public let mangaID: UUID

    public init(mangaID: UUID) {
      self.mangaID = mangaID
    }
  }

  public enum Action: Sendable {}

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
