//
//  MangaListView.swift
//
//
//  Created by Long Kim on 14/3/24.
//

import ComposableArchitecture
import MangaListCore
import SwiftUI

public struct MangaListView: View {
  public let store: StoreOf<MangaListFeature>

  public init(store: StoreOf<MangaListFeature>) {
    self.store = store
  }

  public var body: some View {
    List(store.mangas) { manga in
      Text(manga.title)
    }
  }
}
