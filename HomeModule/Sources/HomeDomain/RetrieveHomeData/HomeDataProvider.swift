//
//  HomeDataProvider.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APIClient
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
package struct HomeDataProvider {
  package var retrieveHomeData: () async throws -> HomeData
}

extension HomeDataProvider: DependencyKey {
  package static var liveValue: HomeDataProvider {
    HomeDataProvider(retrieveHomeData: {
      async let popularMangas = try await MangaEndpoint.listMangas(parameters: ListMangasParameters(
        createdAtSince: .lastMonth,
        order: ListMangasSortOrder(followedCount: .descending)
      ))

      async let recentMangas = try await MangaEndpoint.listMangas(parameters: ListMangasParameters(
        limit: 15,
        order: ListMangasSortOrder(createdAt: .descending)
      ))

      return try await HomeData(popular: popularMangas.mangas, recentlyAdded: recentMangas.mangas)
    })
  }
}

// MARK: - Private

extension Date {
  fileprivate static var lastMonth: Date? {
    Calendar.current.date(byAdding: .month, value: -1, to: Date(), wrappingComponents: false)
  }
}
