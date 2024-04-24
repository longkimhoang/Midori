//
//  MangaRepository.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Dependencies
import DependenciesMacros
import Models
import Networking
import SwiftData

@DependencyClient
public struct MangaRepositoryClient: Sendable {
  public typealias Manga = Models.Manga

  public var importMangas: @Sendable ([Networking.Manga]) async throws -> Void
  public var fetchMangas: @Sendable (
    _ descriptor: FetchDescriptor<Manga>,
    _ context: ModelContext
  ) async throws -> [Manga]
}

extension MangaRepositoryClient: DependencyKey {
  public static var liveValue: MangaRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer

    return MangaRepositoryClient(
      importMangas: { mangas in
        let importer = MangaImporter(modelContainer: modelContainer)
        try await importer.importMangas(mangas)
      },
      fetchMangas: { _, _ in
        fatalError()
      }
    )
  }

  public static let testValue = MangaRepositoryClient()
}

public extension DependencyValues {
  var mangaRepository: MangaRepositoryClient {
    get { self[MangaRepositoryClient.self] }
    set { self[MangaRepositoryClient.self] = newValue }
  }
}

// MARK: - Implementation

@ModelActor
actor MangaImporter {
  typealias Manga = Models.Manga

  func importMangas(_ mangas: [Networking.Manga]) throws {
    for manga in mangas {
      let cover = manga.relationship(CoverRelationship.self).flatMap(\.referenced)
      let model = Manga(
        mangaID: manga.id,
        title: LocalizedString(manga.title),
        overview: manga.description.map(LocalizedString.init),
        cover: cover.map { .init(fileName: $0.fileName, volume: $0.volume) },
        createdAt: manga.createdAt
      )

      modelContext.insert(model)
    }

    try modelContext.save()
  }
}
