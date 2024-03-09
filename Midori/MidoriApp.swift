//
//  MidoriApp.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import Database
import Dependencies
import SwiftData
import SwiftUI

@main
struct MidoriApp: App {
  @Dependency(\.modelContainer) var modelContainer

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(modelContainer)
  }
}
