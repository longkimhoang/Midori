//
//  ChapterRepositoryClient.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Dependencies
import DependenciesMacros
import Foundation
import IdentifiedCollections
import Networking
import SwiftData

@DependencyClient
public struct ChapterRepositoryClient: Sendable {
  public var importChapters: @Sendable (_ chapters: [Networking.Chapter]) async throws -> Void
  @DependencyEndpoint(method: "fetchChapters")
  public var fetchChaptersUsingIDs: @Sendable (
    _ ids: [UUID],
    _ context: ModelContext
  ) throws -> [Chapter]
  @DependencyEndpoint(method: "fetchChapters")
  public var fetchChaptersUsingDescriptor: @Sendable (
    _ descriptor: FetchDescriptor<Chapter>,
    _ context: ModelContext
  ) throws -> [Chapter]
}

extension ChapterRepositoryClient: DependencyKey {
  public static var liveValue: ChapterRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer
    let repository = ChapterRepository(modelContainer: modelContainer)

    return ChapterRepositoryClient(
      importChapters: { chapters in
        try await repository.importChapters(chapters)
      },
      fetchChaptersUsingIDs: { ids, context in
        let descriptor = FetchDescriptor<Chapter>(predicate: #Predicate {
          ids.contains($0.chapterID) && $0.manga != nil
        })
        return try context.fetch(descriptor)
      },
      fetchChaptersUsingDescriptor: { descriptor, context in
        try context.fetch(descriptor)
      }
    )
  }

  public static let testValue = ChapterRepositoryClient()
}

public extension DependencyValues {
  var chapterRepository: ChapterRepositoryClient {
    get { self[ChapterRepositoryClient.self] }
    set { self[ChapterRepositoryClient.self] = newValue }
  }
}

// MARK: - Implementation

@ModelActor
actor ChapterRepository {
  func importChapters(_ chapters: [Networking.Chapter]) throws {
    // Fetch mangas to set up relationship to the chapter
    let mangaIDs = chapters.compactMap { $0.relationship(MangaRelationship.self) }.map(\.id)
    var mangasFetchDescriptor = FetchDescriptor<Manga>(
      predicate: #Predicate { mangaIDs.contains($0.mangaID) }
    )
    mangasFetchDescriptor.propertiesToFetch = [\.mangaID]
    let mangas = try IdentifiedArray(
      uniqueElements: modelContext.fetch(mangasFetchDescriptor),
      id: \.mangaID
    )

    let models = chapters.map { chapter in
      let model = Chapter(
        chapterID: chapter.id,
        volume: chapter.volume,
        title: chapter.title,
        chapter: chapter.chapter,
        readableAt: chapter.readableAt
      )
      if let mangaID = chapter.relationship(MangaRelationship.self)?.id,
         let manga = mangas[id: mangaID]
      {
        model.manga = manga
      }

      if let scanlationGroup = chapter.relationship(ScanlationGroupRelationship.self)?.referenced {
        model.scanlationGroup = .init(
          groupID: scanlationGroup.id,
          name: scanlationGroup.name,
          groupDescription: scanlationGroup.description
        )
      }

      return model
    }

    models.forEach { modelContext.insert($0) }
    try modelContext.save()
  }
}
