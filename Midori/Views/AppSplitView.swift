//
//  AppSplitView.swift
//  Midori
//
//  Created by Long Kim on 11/3/24.
//

#if os(macOS)
import HomeUI
import SwiftUI

struct AppSplitView: View {
  @SceneStorage("sidebarItem") private var destination: AppDestination = .home

  var body: some View {
    NavigationSplitView {
      List(AppDestination.allCases, id: \.self, selection: $destination) { destination in
        NavigationLink(value: destination) {
          destination.label
        }
      }
      .toolbarTitleDisplayMode(.inline)
    } detail: {
      switch destination {
      case .home:
        HomeView()
      }
    }
  }
}

private extension AppDestination {
  var label: some View {
    switch self {
    case .home:
      Label("Home", systemImage: "house")
    }
  }
}
#endif
