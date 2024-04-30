//
//  MangaDetailScene.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import ComposableArchitecture
import Foundation
import MangaDetailCore
import SwiftUI

/// A scene for displaying a single manga.
public struct MangaDetailScene: Scene {
  public var body: some Scene {
    WindowGroup(id: "Midori.MangaDetail", for: UUID.self) { $mangaID in
      if let mangaID {
        ContentView(mangaID: mangaID)
      }
    }
  }

  public init() {}

  struct ContentView: View {
    @State private var store: StoreOf<MangaDetailFeature>

    init(mangaID: UUID) {
      let store = Store(initialState: MangaDetailFeature.State(mangaID: mangaID)) {
        MangaDetailFeature()
      }

      _store = State(initialValue: store)
    }

    var body: some View {
      MangaDetailView(store: store)
    }
  }
}
