//
//  MangaListFeature.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import ComposableArchitecture
import Foundation

@Reducer
public struct MangaListFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var mangas: IdentifiedArrayOf<Manga> = []
    public var layout: Layout = .list

    public init() {}
  }

  public enum Action: Sendable {
    public enum Delegate: Sendable {
      case refresh
      case listEndReached
      case mangaSelected(Manga.ID)
    }

    case selectLayout(Layout)
    case delegate(Delegate)
  }

  public enum Layout: Sendable {
    case list
    case grid
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .selectLayout(layout):
        state.layout = layout
        return .none
      case .delegate:
        return .none
      }
    }
  }
}
