//
//  ChapterImporter.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import APIModels
import CoreData
import Dependencies
import Foundation
import IdentifiedCollections
import Persistence

public protocol ChapterImporterProtocol {
  func importChapters(_ chapters: some Collection<APIModels.Chapter>) async throws
}

struct ChapterImporter: ChapterImporterProtocol {
  @Dependency(\.persistenceController.container) var persistenceContainer

  func importChapters(_ chapters: some Collection<APIModels.Chapter>) async throws {
    let context = persistenceContainer.newBackgroundContext()
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    let identifiedChapters = IdentifiedArray(chapters, uniquingIDsWith: { $1 })
    let chapterIDs = try await context.perform {
      var iterator = identifiedChapters.makeIterator()
      let request = NSBatchInsertRequest(
        entity: Chapter.entity(),
        managedObjectHandler: { managedObject in
          if let model = iterator.next(),
             let chapter = managedObject as? Persistence.Chapter
          {
            chapter.chapterID = model.id
            chapter.title = model.attributes.title
            chapter.chapter = model.attributes.chapter
            return false
          } else {
            return true
          }
        }
      )
      request.resultType = .objectIDs

      let result = try context.execute(request) as! NSBatchInsertResult
      return result.result as! [NSManagedObjectID]
    }

    // Link chapter to mangas (if available)
    let mangaIDs = identifiedChapters.compactMap(\.mangaID)

    try await context.perform {
      // Fetch mangas
      let mangaFetchRequest = NSFetchRequest<Persistence.Manga>(entityName: "Manga")
      mangaFetchRequest.predicate = NSPredicate(format: "mangaID in %@", mangaIDs)

      let mangas = try IdentifiedArray(
        uniqueElements: context.fetch(mangaFetchRequest),
        id: \.mangaID
      )

      for chapterID in chapterIDs {
        guard let chapter = context.object(with: chapterID) as? Persistence.Chapter,
              let mangaID = identifiedChapters[id: chapter.chapterID].flatMap(\.mangaID),
              let manga = mangas[id: mangaID]
        else {
          continue
        }

        chapter.manga = manga
      }

      try context.save()
    }
  }
}

extension APIModels.Chapter {
  fileprivate var mangaID: UUID? {
    relationships.first(MangaRelationship.self)?.id
  }
}

private struct ChapterImporterKey: DependencyKey {
  static let liveValue: any ChapterImporterProtocol = ChapterImporter()
}

extension DependencyValues {
  public var chapterImporter: any ChapterImporterProtocol {
    get { self[ChapterImporterKey.self] }
    set { self[ChapterImporterKey.self] = newValue }
  }
}
