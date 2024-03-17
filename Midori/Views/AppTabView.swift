//
//  AppTabView.swift
//  Midori
//
//  Created by Long Kim on 11/3/24.
//

import HomeUI
import SwiftUI

struct AppTabView: View {
  @SceneStorage("selectedTab") private var destination: AppDestination = .home

  var body: some View {
    TabView(selection: $destination) {
      HomeView()
        .tabItem {
          Label("Home", systemImage: "house")
        }
        .tag(AppDestination.home)
    }
  }
}
