//
//  ContentView.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import ComposableArchitecture
import HomeModule
import SwiftUI

struct ContentView: View {
  let store: StoreOf<AppFeature>

  var body: some View {
    TabView {
      HomeView(store: store.scope(state: \.home, action: \.home))
        .tabItem {
          Label("Home", systemImage: "house")
        }
    }
  }
}

#Preview {
  ContentView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}
