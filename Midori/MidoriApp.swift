//
//  MidoriApp.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import CoreData
import Dependencies
import Persistence
import SwiftUI

@main
struct MidoriApp: App {
  @Dependency(PersistenceController.self) var persistenceController

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}
