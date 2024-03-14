//
//  MangaListFeature.swift
//
//
//  Created by Long Kim on 14/3/24.
//

import ComposableArchitecture
import Database

@Reducer
public struct MangaListFeature {
  @ObservableState
  public struct State {
    public var mangas: IdentifiedArrayOf<Manga> = []

    public init() {}
  }

  public init() {}
}
