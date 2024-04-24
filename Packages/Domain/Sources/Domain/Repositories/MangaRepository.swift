//
//  MangaRepository.swift
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
  public var fetchMangasUsingDescriptor: @Sendable @MainActor (
    _ descriptor: FetchDescriptor<Manga>
  ) throws -> [Manga]
  @DependencyEndpoint(method: "fetchMangas")
  public var fetchMangasUsingMangaIDs: @Sendable @MainActor (_ mangaIDs: [UUID]) throws -> [Manga]
}

extension MangaRepositoryClient: DependencyKey {
  public static var liveValue: MangaRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer

    return MangaRepositoryClient(
      importMangas: { mangas in
        let importer = MangaImporter(modelContainer: modelContainer)
        try await importer.importMangas(mangas)
      },
      fetchMangasUsingDescriptor: { descriptor in
        try modelContainer.mainContext.fetch(descriptor)
      },
      fetchMangasUsingMangaIDs: { ids in
        var descriptor = FetchDescriptor<Manga>()
        descriptor.predicate = #Predicate { ids.contains($0.mangaID) }
        descriptor.propertiesToFetch = [\.mangaID]

        let models = try IdentifiedArray(
          uniqueElements: modelContainer.mainContext.fetch(descriptor),
          id: \.mangaID
        )

        return ids.compactMap { models[id: $0] }
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
