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
import IdentifiedCollections
import Persistence

public protocol MangaImporterProtocol {
  func importMangas(_ mangas: some Collection<APIModels.Manga>) async throws
}

struct MangaImporter: MangaImporterProtocol {
  @Dependency(\.persistenceController.container) var persistenceContainer

  func importMangas(_ mangas: some Collection<APIModels.Manga>) async throws {
    let context = persistenceContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    // Import authors
    let artistIDs = try await context.perform {
      var iterator = mangas.makeIterator()
      let request = NSBatchInsertRequest(
        entity: Author.entity(),
        managedObjectHandler: { managedObject in
          if let model = iterator.next(),
             let artist = model.artist,
             let managedObject = managedObject as? Persistence.Author
          {
            managedObject.authorID = artist.id
            managedObject.name = artist.attributes.name
            managedObject.imageURL = artist.attributes.imageURL
            return false
          } else {
            return true
          }
        }
      )
      request.resultType = .objectIDs
      let batchInsertResult = try context.execute(request) as! NSBatchInsertResult
      return batchInsertResult.result as! [NSManagedObjectID]
    }

    let mangaIDs = try await context.perform {
      var iterator = mangas.makeIterator()
      let request = NSBatchInsertRequest(
        entity: Manga.entity(),
        managedObjectHandler: { managedObject in
          if let model = iterator.next(), let managedObject = managedObject as? Persistence.Manga {
            managedObject.mangaID = model.id
            managedObject.title = model.attributes.title.value
            managedObject.coverImageURL = model.coverImageURL
            return false
          } else {
            return true
          }
        }
      )
      request.resultType = .objectIDs
      let batchInsertResult = try context.execute(request) as! NSBatchInsertResult
      return batchInsertResult.result as! [NSManagedObjectID]
    }

    try await context.perform {
      let mangaObjects = mangaIDs.map { context.object(with: $0) as! Persistence.Manga }
      let identifiedMangas = IdentifiedArray(mangas, uniquingIDsWith: { $1 })

      let artistObjects = IdentifiedArray(
        artistIDs.map { context.object(with: $0) as! Persistence.Author },
        id: \.authorID,
        uniquingIDsWith: { $1 }
      )

      for mangaObject in mangaObjects {
        if let manga = identifiedMangas[id: mangaObject.mangaID],
           let artist = manga.artist,
           let artistObject = artistObjects[id: artist.id]
        {
          mangaObject.artist = artistObject
        }
      }

      try context.save()
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
