//
//  PopularMangasClient.swift
//
//
//  Created by Long Kim on 08/03/2024.
//

import APIClients
import Database
import Dependencies
import DependenciesMacros
import Domain
import Foundation
import SwiftData

@DependencyClient
struct PopularMangasClient {
  var fetch: () async throws -> [Manga]
  var restore: @MainActor (_ ids: [Manga.ID]) throws -> [Manga]
}

extension PopularMangasClient: DependencyKey {
  static var liveValue: Self {
    @Dependency(\.calendar) var calendar
    @Dependency(\.date) var date
    @Dependency(\.mangaAPI) var mangaAPI
    @Dependency(\.mangaStore) var mangaStore

    return PopularMangasClient(
      fetch: {
        let lastMonth = calendar.date(
          byAdding: .month,
          value: -1,
          to: date(),
          wrappingComponents: false
        )

        let popularMangas = try await mangaAPI.listMangas(
          parameters: ListMangasParameters(
            createdAtSince: lastMonth,
            order: ListMangasSortOrder(followedCount: .descending)
          )
        )

        try await mangaStore.import(mangas: popularMangas.mangas)

        let mangaIDs = popularMangas.mangas.map(\.id)
        return try await mangaStore.queryByIDs(mangaIDs) {
          $0.propertiesToFetch = [\.title, \.coverImageURL, \.mangaID]
          $0.relationshipKeyPathsForPrefetching = [\.artist, \.author]
        }
        .sorted(by: \.mangaID, using: mangaIDs)
      },
      restore: { ids in
        var descriptor = FetchDescriptor<Manga>()
        descriptor.predicate = #Predicate<Manga> { manga in
          ids.contains(manga.persistentModelID)
        }
        descriptor.propertiesToFetch = [\.title, \.coverImageURL, \.mangaID]
        descriptor.relationshipKeyPathsForPrefetching = [\.artist, \.author]

        return try mangaStore
          .query(fetchDescriptor: descriptor)
          .sorted(by: \.persistentModelID, using: ids)
      }
    )
  }
}

extension Collection {
  func sorted<T: Hashable>(
    by keyPath: KeyPath<Element, T>,
    using order: some Collection<T>
  ) -> [Element] {
    let keyedElements: [T: Element] = reduce(into: [:]) { dict, element in
      let key = element[keyPath: keyPath]
      dict[key] = element
    }

    return order.compactMap { keyedElements[$0] }
  }
}

extension DependencyValues {
  var popularMangas: PopularMangasClient {
    get { self[PopularMangasClient.self] }
    set { self[PopularMangasClient.self] = newValue }
  }
}
