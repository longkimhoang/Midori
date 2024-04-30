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
import Networking
import SwiftData

@DependencyClient
public struct MangaRepositoryClient: Sendable {
  public var importMangas: @Sendable ([Networking.Manga]) async throws -> Void
  @DependencyEndpoint(method: "fetchMangas")
  public var fetchMangasUsingIDs: @Sendable (
    _ ids: [UUID],
    _ context: ModelContext
  ) throws -> [Manga]
  @DependencyEndpoint(method: "fetchMangas")
  public var fetchMangasUsingDescriptor: @Sendable (
    _ descriptor: FetchDescriptor<Manga>,
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
        let descriptor = FetchDescriptor<Manga>(
          predicate: #Predicate { ids.contains($0.mangaID) && $0.author != nil }
        )
        return try context.fetch(descriptor)
      },
      fetchMangasUsingDescriptor: { descriptor, context in
        try context.fetch(descriptor)
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
  func importMangas(_ mangas: [Networking.Manga]) throws {
    let models = mangas.map { manga in
      let cover = manga.relationship(CoverRelationship.self).flatMap(\.referenced)
      let author = manga.relationship(AuthorRelationship.self).flatMap(\.referenced)
      let artist = manga.relationship(ArtistRelationship.self).flatMap(\.referenced)
      let model = Manga(
        mangaID: manga.id,
        title: .init(manga.title),
        overview: manga.description.map(LocalizedString.init),
        cover: cover.map { .init(id: $0.id, fileName: $0.fileName, volume: $0.volume) },
        createdAt: manga.createdAt
      )

      if let author {
        let authorModel = Author(
          authorID: author.id,
          name: author.name,
          imageURL: author.imageURL
        )

        model.author = authorModel
      }

      // Artist might be the same as author, in that case
      if let artist, artist.id != author?.id {
        model.artist = Artist(
          artistID: artist.id,
          name: artist.name,
          imageURL: artist.imageURL
        )
      }

      return model
    }

    models.forEach { modelContext.insert($0) }
    try modelContext.save()
  }
}
