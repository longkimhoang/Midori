//
//  RecentlyAddedView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import ComposableArchitecture
import Home
import SwiftUI

struct RecentlyAddedView: View {
  @Environment(\.locale) private var locale

  @Bindable var store: StoreOf<RecentlyAddedFeature>

  var body: some View {
    List(store.mangaList.mangas) {
      Text($0.title.localized(for: locale))
    }
    .navigationTitle(Text("Recently Added", bundle: .module))
    .toolbarTitleDisplayMode(.inline)
    .task {
      await store.send(.fetchMangas).finish()
    }
  }
}
