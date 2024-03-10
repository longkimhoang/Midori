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
  var body: some View {
    HomeView(
      store: Store(initialState: HomeFeature.State()) {
        HomeFeature()
      }
    )
  }
}

#Preview {
  ContentView()
}
