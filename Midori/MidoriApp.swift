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
  @Dependency(\.persistenceController.container.viewContext) var viewContext

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .environment(\.managedObjectContext, viewContext)
  }
}
