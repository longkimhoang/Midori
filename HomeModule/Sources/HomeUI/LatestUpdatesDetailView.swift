//
//  LatestUpdatesDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import HomeCore
import SwiftUI

struct LatestUpdatesDetailView: View {
  let store: StoreOf<LatestUpdatesDetailFeature>

  var body: some View {
    List(store.chapters) { chapter in
      Text(chapter.chapterID.uuidString)
    }
    .navigationTitle(Text("Latest updates", bundle: .module))
  }
}
