//
//  RecentlyAddedMangasClient.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Database
import Dependencies
import DependenciesMacros
import Domain
import Foundation
import MangaEndpoint
import SwiftData

@DependencyClient
struct RecentlyAddedMangasClient {
  var fetch: () async throws -> [Manga]
}

extension RecentlyAddedMangasClient: DependencyKey {
  static var liveValue: Self {
    @Dependency(\.mangaStore) var mangaStore

    return RecentlyAddedMangasClient(
      fetch: {
        let recentlyAddedMangas = try await MangaEndpoint
          .listMangas(parameters: ListMangasParameters(
            limit: 15,
            order: ListMangasSortOrder(createdAt: .descending)
          ))

        try await mangaStore.import(mangas: recentlyAddedMangas.mangas)

        let mangaIDs = recentlyAddedMangas.mangas.map(\.id)
        return try await mangaStore.queryByIDs(mangaIDs) {
          $0.propertiesToFetch = [\.title, \.coverImageURL]
          $0.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        }
      }
    )
  }
}

extension DependencyValues {
  var recentlyAddedMangas: RecentlyAddedMangasClient {
    get { self[RecentlyAddedMangasClient.self] }
    set { self[RecentlyAddedMangasClient.self] = newValue }
  }
}
