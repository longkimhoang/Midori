//
//  AppView.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import ComposableArchitecture
import HomeModule
import SwiftUI

struct AppView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.verticalSizeClass) var verticalSizeClass
  let store: StoreOf<AppFeature>

  var body: some View {
    if shouldUseTabView {
      AppTabView(store: store)
    } else {
      AppSplitView(store: store)
    }
  }

  private var shouldUseTabView: Bool {
    horizontalSizeClass == .compact || verticalSizeClass == .compact
  }
}

#Preview {
  AppView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}
