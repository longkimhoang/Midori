//
//  RecentlyAddedMangasClient.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import APIClients
import Database
import Dependencies
import DependenciesMacros
import Domain
import Foundation
import SwiftData

struct FetchRecentlyAddedMangasParameters {
  var limit: Int = 15
  var offset: Int?
}

@DependencyClient
struct RecentlyAddedMangasClient {
  var fetch: (_ parameters: FetchRecentlyAddedMangasParameters) async throws -> [Manga]
}

extension RecentlyAddedMangasClient: DependencyKey {
  static var liveValue: Self {
    @Dependency(\.mangaAPI) var mangaAPI
    @Dependency(\.mangaStore) var mangaStore

    return RecentlyAddedMangasClient(
      fetch: { parameters in
        let recentlyAddedMangas = try await mangaAPI.listMangas(
          parameters: ListMangasParameters(
            limit: parameters.limit,
            offset: parameters.offset,
            order: ListMangasSortOrder(createdAt: .descending)
          )
        )

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

extension RecentlyAddedMangasClient {
  func fetch() async throws -> [Manga] {
    try await fetch(parameters: FetchRecentlyAddedMangasParameters())
  }
}

extension DependencyValues {
  var recentlyAddedMangas: RecentlyAddedMangasClient {
    get { self[RecentlyAddedMangasClient.self] }
    set { self[RecentlyAddedMangasClient.self] = newValue }
  }
}
