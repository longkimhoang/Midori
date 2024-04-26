//
//  MangaRepositoryClient.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Dependencies
import DependenciesMacros
import Foundation
import IdentifiedCollections
import Models
import Networking
import SwiftData

@DependencyClient
public struct MangaRepositoryClient: Sendable {
  public typealias Manga = Models.Manga

  public var importMangas: @Sendable ([Networking.Manga]) async throws -> Void
  @DependencyEndpoint(method: "fetchMangas")
  public var fetchMangasUsingIDs: @Sendable (
    _ ids: [UUID],
    _ context: ModelContext
  ) throws -> [Manga]
}

extension MangaRepositoryClient: DependencyKey {
  public static var liveValue: MangaRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer

    return MangaRepositoryClient(
      importMangas: { mangas in
        let importer = MangaImporter(modelContainer: modelContainer)
        try await importer.importMangas(mangas)
      },
      fetchMangasUsingIDs: { ids, context in
        let descriptor = FetchDescriptor<Manga>(predicate: #Predicate { ids.contains($0.mangaID) })
        return try context.fetch(descriptor)
      }
    )
  }

  public static var testValue: MangaRepositoryClient {
    MangaRepositoryClient()
  }
}

public extension DependencyValues {
  var mangaRepository: MangaRepositoryClient {
    get { self[MangaRepositoryClient.self] }
    set { self[MangaRepositoryClient.self] = newValue }
  }
}

// MARK: - Importer

@ModelActor
actor MangaImporter {
  typealias Manga = Models.Manga

  func importMangas(_ mangas: [Networking.Manga]) throws {
    let models = mangas.map { manga in
      let cover = manga.relationship(CoverRelationship.self).flatMap(\.referenced)
      return Manga(
        mangaID: manga.id,
        title: .init(manga.title),
        overview: manga.description.map(LocalizedString.init),
        cover: cover.map { .init(fileName: $0.fileName, volume: $0.volume) },
        createdAt: manga.createdAt
      )
    }

    models.forEach { modelContext.insert($0) }
    try modelContext.save()
  }
}
