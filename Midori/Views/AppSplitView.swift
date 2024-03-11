//
//  AppSplitView.swift
//  Midori
//
//  Created by Long Kim on 11/3/24.
//

import ComposableArchitecture
import HomeModule
import SwiftUI

struct AppSplitView: View {
  enum Destination: Hashable, CaseIterable {
    case home
  }

  @State private var destination: Destination? = .home
  let store: StoreOf<AppFeature>

  var body: some View {
    NavigationSplitView {
      List(Destination.allCases, id: \.self, selection: $destination) { destination in
        NavigationLink(value: destination) {
          destination.label
        }
      }
      .toolbarTitleDisplayMode(.inline)
    } detail: {
      switch destination {
      case .home:
        HomeView(store: store.scope(state: \.home, action: \.home))
      case .none:
        EmptyView()
      }
    }
  }
}

extension AppSplitView.Destination {
  @ViewBuilder
  fileprivate var label: some View {
    switch self {
    case .home:
      Label("Home", systemImage: "house")
    }
  }
}
