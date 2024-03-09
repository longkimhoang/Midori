//
//  ModelContainer.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Dependencies
import SwiftData

extension ModelContainer: DependencyKey {
  public static var liveValue: ModelContainer {
    return try! ModelContainer(
      for: Manga.self, Chapter.self, Artist.self, Author.self
    )
  }
}

extension DependencyValues {
  var modelContainer: ModelContainer {
    get { self[ModelContainer.self] }
    set { self[ModelContainer.self] = newValue }
  }
}
