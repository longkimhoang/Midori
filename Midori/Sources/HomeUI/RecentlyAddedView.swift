//
//  RecentlyAddedView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import ComposableArchitecture
import HomeCore
import MangaListUI
import SwiftUI

struct RecentlyAddedView: View {
  @Environment(\.locale) private var locale

  @Bindable var store: StoreOf<RecentlyAddedFeature>

  var body: some View {
    MangaListView(store: store.scope(state: \.mangaList, action: \.mangaList))
      .navigationTitle(Text("Recently Added", bundle: .module))
      .toolbarTitleDisplayMode(.inline)
      .task {
        await store.send(.fetchMangas).finish()
      }
  }
}
