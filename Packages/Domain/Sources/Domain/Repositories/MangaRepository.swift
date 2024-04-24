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
  public var importMangas: @Sendable ([Networking.Manga]) async throws -> Void
}

extension MangaRepositoryClient: DependencyKey {
  public static var liveValue: MangaRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer

    return MangaRepositoryClient(
      importMangas: { mangas in
        let importer = MangaImporter(modelContainer: modelContainer)
        try await importer.importMangas(mangas)
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
      let model = Manga(
        mangaID: manga.id,
        title: LocalizedString(manga.attributes.title),
        overview: nil,
        coverImageURL: nil,
        createdAt: manga.attributes.createdAt
      )

      modelContext.insert(model)
    }

    try modelContext.save()
  }
}
