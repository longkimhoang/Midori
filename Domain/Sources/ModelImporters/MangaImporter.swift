//
//  MangaImporter.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import APIModels
import CoreData
import Dependencies
import Foundation
import Persistence

private typealias Manga = Persistence.Manga

public protocol MangaImporterProtocol {
  func importMangas(_ mangas: some Collection<APIModels.Manga>) async throws
}

struct MangaImporter: MangaImporterProtocol {
  @Dependency(\.persistenceController.container) var persistenceContainer

  func importMangas(_ mangas: some Collection<APIModels.Manga>) async throws {
    let context = persistenceContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    try await context.perform {
      var iterator = mangas.makeIterator()
      let request = NSBatchInsertRequest(
        entity: Manga.entity(),
        managedObjectHandler: { managedObject in
          if let model = iterator.next(), let managedObject = managedObject as? Manga {
            managedObject.mangaID = model.id
            return false
          } else {
            return true
          }
        }
      )

      try context.execute(request)
    }
  }
}

private struct MangaImporterKey: DependencyKey {
  static let liveValue: any MangaImporterProtocol = MangaImporter()
}

extension DependencyValues {
  public var mangaImporter: any MangaImporterProtocol {
    get { self[MangaImporterKey.self] }
    set { self[MangaImporterKey.self] = newValue }
  }
}
