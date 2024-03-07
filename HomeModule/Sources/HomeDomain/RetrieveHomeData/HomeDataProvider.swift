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
private typealias Chapter = Persistence.Chapter

@DependencyClient
package struct HomeDataProvider {
  package var retrieveHomeData: @MainActor () async throws -> HomeData
}

extension HomeDataProvider: DependencyKey {
  package static var liveValue: HomeDataProvider {
    HomeDataProvider(retrieveHomeData: {
      @Dependency(\.persistenceController.container.viewContext) var viewContext
      @Dependency(\.mangaImporter) var mangaImporter
      @Dependency(\.chapterImporter) var chapterImporter

      @Sendable
      func fetchLatestChapters() async throws -> ListChapters {
        let latestChapters = try await ChapterEndpoint
          .listChapters(
            parameters: ListChaptersParameters(
              limit: 16,
              includes: [.scanlationGroup],
              order: ListChaptersSortOrder(readableAt: .descending)
            )
          )

        let latestMangaIDs = latestChapters.chapters
          .compactMap { $0.relationships.first(MangaRelationship.self) }
          .map(\.id)

        let latestMangas = try await MangaEndpoint
          .listMangas(
            parameters: ListMangasParameters(
              limit: 100,
              ids: latestMangaIDs.map { $0.uuidString.lowercased() },
              includes: [.cover]
            )
          )

        try await mangaImporter.importMangas(latestMangas.mangas)
        return latestChapters
      }

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

      async let latestChapters = try await fetchLatestChapters()

      try await mangaImporter.importMangas(chain(popularMangas.mangas, recentMangas.mangas))
      try await chapterImporter.importChapters(latestChapters.chapters)

      // Fetch the models into view context
      func getMappedMangas(from listMangas: ListMangas) throws -> HomeData.Mangas {
        let mangaIDs = listMangas.mangas.map(\.id)
        let request = NSFetchRequest<Manga>(entityName: "Manga")
        let predicate = #Predicate<Manga> {
          mangaIDs.contains($0.mangaID)
        }
        request.predicate = NSPredicate(predicate)
        let identifiedMangas = try IdentifiedArray(
          uniqueElements: viewContext.fetch(request),
          id: \.mangaID
        )
        return IdentifiedArray(uniqueElements: mangaIDs.compactMap { identifiedMangas[id: $0] })
      }

      func getMapedChapters(from listChapters: ListChapters) throws -> HomeData.Chapters {
        let chapterIDs = listChapters.chapters.map(\.id)
        let request = NSFetchRequest<Chapter>(entityName: "Chapter")
        let predicate = #Predicate<Chapter> {
          chapterIDs.contains($0.chapterID)
        }
        request.predicate = NSPredicate(predicate)
        let identifiedMangas = try IdentifiedArray(
          uniqueElements: viewContext.fetch(request),
          id: \.chapterID
        )
        return IdentifiedArray(uniqueElements: chapterIDs.compactMap { identifiedMangas[id: $0] })
      }

      return try await HomeData(
        popular: getMappedMangas(from: popularMangas),
        latestChapters: getMapedChapters(from: latestChapters),
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

extension Collection {
  fileprivate func chained(with other: some Collection<Element>) -> some Collection<Element> {
    chain(self, other)
  }
}
