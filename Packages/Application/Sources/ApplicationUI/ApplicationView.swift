//
//  ApplicationView.swift
//
//
//  Created by Long Kim on 21/4/24.
//

import Application
import Common
import ComposableArchitecture
import SwiftUI

public struct ApplicationView: View {
  @Bindable public var store: StoreOf<ApplicationFeature>

  public init(store: StoreOf<ApplicationFeature>) {
    self.store = store
  }

  public var body: some View {
    TabView(selection: $store.selectedTab.sending(\.selectTab)) {
      NavigationStack {
        ColorView()
          .navigationTitle("Hello")
          .providingLayoutMargins()
      }
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

private struct ColorView: View {
  @Environment(\.layoutMarginsGuide) var layoutMargins

  var body: some View {
    Color.purple
      .padding(.leading, layoutMargins.leading)
      .padding(.trailing, layoutMargins.trailing)
  }
}
