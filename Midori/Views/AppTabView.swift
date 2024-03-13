//
//  AppTabView.swift
//  Midori
//
//  Created by Long Kim on 11/3/24.
//

import ComposableArchitecture
import HomeUI
import SwiftUI

struct AppTabView: View {
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
