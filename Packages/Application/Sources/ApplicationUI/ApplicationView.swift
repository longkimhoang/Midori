//
//  ApplicationView.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import Application
import ComposableArchitecture
import SwiftUI

public struct ApplicationView: View {
  @Bindable public var store: StoreOf<ApplicationFeature>

  public init(store: StoreOf<ApplicationFeature>) {
    self.store = store
  }

  public var body: some View {
    TabView(selection: $store.selectedTab.sending(\.selectTab)) {
      Text("Home")
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
