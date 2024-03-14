//
//  RecentlyAddedDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import HomeCore
import SwiftUI

struct RecentlyAddedDetailView: View {
  let store: StoreOf<RecentlyAddedDetailFeature>

  var body: some View {
    List(store.mangas) { manga in
      Text(manga.title)
    }
    .navigationTitle(Text("Recently added", bundle: .module))
  }
}
