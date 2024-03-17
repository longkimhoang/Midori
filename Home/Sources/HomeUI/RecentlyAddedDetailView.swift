//
//  RecentlyAddedDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import HomeCore
import MangaListUI
import SwiftUI

struct RecentlyAddedDetailView: View {
  @Environment(\.isPresented) private var isPresented
  @StateObject private var model = RecentlyAddedDetailModel()

  var body: some View {
    MangaListView(mangas: model.mangas)
      .environment(\.mangaListEndReached, MangaListEndReachedAction {})
      .navigationTitle(Text("Recently added", bundle: .module))
      .toolbarTitleDisplayMode(.inline)
      .onChange(of: isPresented, initial: true) { _, isPresented in
        if isPresented {
          model.fetchInitialMangas()
        }
      }
  }
}
