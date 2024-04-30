//
//  ApplicationView.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import ApplicationCore
import ComposableArchitecture
import HomeUI
import SwiftUI

struct ApplicationView: View {
  @State private var store = Store(initialState: ApplicationFeature.State()) {
    ApplicationFeature()
  }

  var body: some View {
    TabView(selection: $store.selectedTab.sending(\.selectTab)) {
      HomeView(store: store.scope(state: \.home, action: \.home))
        .tabItem {
          Label("Home", systemImage: "house")
        }
        .tag(ApplicationFeature.Tab.home)

      Text("Search")
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
        .tag(ApplicationFeature.Tab.search)
    }
  }
}
