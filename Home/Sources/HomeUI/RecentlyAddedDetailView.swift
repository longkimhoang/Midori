//
//  RecentlyAddedDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import HomeCore
import MangaListUI
import SwiftUI

struct RecentlyAddedDetailView: View {
  let store: StoreOf<RecentlyAddedDetailFeature>

  var body: some View {
    MangaListView(store: store.scope(state: \.mangaList, action: \.mangaList))
      .navigationTitle(Text("Recently added", bundle: .module))
  }
}
