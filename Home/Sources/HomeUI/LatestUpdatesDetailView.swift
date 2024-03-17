//
//  LatestUpdatesDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import HomeCore
import SwiftUI

struct LatestUpdatesDetailView: View {
  @Environment(\.isPresented) private var isPresented
  @StateObject private var model = LatestUpdatesDetailModel()

  var body: some View {
    List(model.chapters) { chapter in
      Text(chapter.chapterID.uuidString)
    }
    .navigationTitle(Text("Latest updates", bundle: .module))
    .onChange(of: isPresented, initial: true) { _, isPresented in
      if isPresented {
        model.fetchInitialChapters()
      }
    }
  }
}
