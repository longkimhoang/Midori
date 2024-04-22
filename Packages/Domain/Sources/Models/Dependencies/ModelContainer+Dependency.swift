//
//  ModelContainer+Dependency.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import Dependencies
import SwiftData

extension ModelContainer: DependencyKey {
  public static var liveValue: ModelContainer {
    do {
      return try ModelContainer(for: Manga.self)
    } catch {
      fatalError("Failed to initialize model container: \(error.localizedDescription)")
    }
  }

  public static var testValue: ModelContainer {
    try! ModelContainer(
      for: Manga.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
  }
}

public extension DependencyValues {
  var modelContainer: ModelContainer {
    get { self[ModelContainer.self] }
    set { self[ModelContainer.self] = newValue }
  }
}
