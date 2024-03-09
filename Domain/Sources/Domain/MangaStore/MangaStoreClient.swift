//
//  MangaStoreClient.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import APIModels
import Database
import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
public struct MangaStoreClient {
  public var query: @MainActor (_ fetchDescriptor: FetchDescriptor<Database.Manga>) throws
    -> [Database.Manga]
  public var `import`: (_ mangas: [APIModels.Manga]) async throws -> Void
}

extension MangaStoreClient: DependencyKey {
  public static var liveValue: MangaStoreClient {
    @Dependency(\.modelContainer) var modelContainer
    let store = MangaStore(modelContainer: modelContainer)

    return MangaStoreClient(
      query: { fetchDescriptor in
        try modelContainer.mainContext.fetch(fetchDescriptor)
      },
      import: { mangas in
        try await store.importMangas(mangas)
      }
    )
  }
}

extension MangaStoreClient {
  @discardableResult
  @MainActor
  public func queryByIDs(
    _ ids: [UUID],
    modifyingDescriptorWith handler: (inout FetchDescriptor<Database.Manga>) -> Void = { _ in }
  ) throws -> [Database.Manga] {
    var fetchDescriptor = FetchDescriptor(
      predicate: #Predicate<Database.Manga> { manga in
        ids.contains(manga.mangaID)
      }
    )
    handler(&fetchDescriptor)

    return try query(fetchDescriptor: fetchDescriptor)
  }
}

extension DependencyValues {
  public var mangaStore: MangaStoreClient {
    get { self[MangaStoreClient.self] }
    set { self[MangaStoreClient.self] = newValue }
  }
}
