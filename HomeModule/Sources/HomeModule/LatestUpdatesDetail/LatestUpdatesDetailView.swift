//
//  LatestUpdatesDetailView.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import ComposableArchitecture
import SwiftUI

struct LatestUpdatesDetailView: View {
  let store: StoreOf<LatestUpdatesDetailFeature>

  var body: some View {
    Text("Latest updates")
      .navigationTitle(Text("Latest updates", bundle: .module))
  }
}
