//
//  HomeDataProvider.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Algorithms
import APIClient
import CoreData
import Dependencies
import DependenciesMacros
import IdentifiedCollections
import ModelImporters
import Persistence

private typealias Manga = Persistence.Manga

@DependencyClient
package struct HomeDataProvider {
  package var retrieveHomeData: @MainActor () async throws -> HomeData
}

extension HomeDataProvider: DependencyKey {
  package static var liveValue: HomeDataProvider {
    HomeDataProvider(retrieveHomeData: {
      @Dependency(\.persistenceController.container.viewContext) var viewContext
      @Dependency(\.mangaImporter) var mangaImporter

      async let popularMangas = try await MangaEndpoint
        .listMangas(parameters: ListMangasParameters(
          createdAtSince: .lastMonth,
          order: ListMangasSortOrder(followedCount: .descending)
        ))

      async let recentMangas = try await MangaEndpoint
        .listMangas(parameters: ListMangasParameters(
          limit: 15,
          order: ListMangasSortOrder(createdAt: .descending)
        ))

      let mangas = try await chain(popularMangas.mangas, recentMangas.mangas)
      try await mangaImporter.importMangas(mangas)

      // Fetch the models into view context
      func getMappedMangas(from listMangas: ListMangas) throws -> HomeData.Mangas {
        let mangaIDs = listMangas.mangas.map(\.id)
        let request = NSFetchRequest<Manga>(entityName: "Manga")
        let predicate = #Predicate<Manga> {
          mangaIDs.contains($0.mangaID)
        }
        request.predicate = NSPredicate(predicate)
        return try IdentifiedArray(uniqueElements: viewContext.fetch(request))
      }

      return try await HomeData(
        popular: getMappedMangas(from: popularMangas),
        recentlyAdded: getMappedMangas(from: recentMangas)
      )
    })
  }
}

// MARK: - Private

extension Date {
  fileprivate static var lastMonth: Date? {
    Calendar.current.date(byAdding: .month, value: -1, to: Date(), wrappingComponents: false)
  }
}
