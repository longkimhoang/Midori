//
//  MidoriApp.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import ComposableArchitecture
import Database
import Dependencies
import SwiftData
import SwiftUI

@main
struct MidoriApp: App {
  @MainActor
  static let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }

  @Dependency(\.modelContainer) var modelContainer

  var body: some Scene {
    WindowGroup {
      ContentView(store: MidoriApp.store)
    }
    .modelContainer(modelContainer)
  }
}
