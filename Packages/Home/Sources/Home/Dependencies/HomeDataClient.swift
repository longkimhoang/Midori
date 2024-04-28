//
//  HomeDataClient.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Dependencies
import DependenciesMacros
import Domain
import Foundation
import IdentifiedCollections
import Networking
import OrderedCollections
import SwiftData

@DependencyClient
struct HomeDataClient: Sendable {
  var retrievePopularMangas: @Sendable () async throws -> IdentifiedArrayOf<Manga>
  var retrieveLatestChapters: @Sendable () async throws -> IdentifiedArrayOf<Chapter>
  var retrieveRecentlyAddedMangas: @Sendable () async throws -> IdentifiedArrayOf<Manga>
}

extension HomeDataClient: DependencyKey {
  static var liveValue: HomeDataClient {
    @Dependency(\.mangaAPI) var mangaAPI
    @Dependency(\.chapterAPI) var chapterAPI
    @Dependency(\.mangaRepository) var mangaRepository
    @Dependency(\.chapterRepository) var chapterRepository
    @Dependency(\.modelContainer) var modelContainer
    let storeCoordinator = StoreCoordinator(modelContainer: modelContainer)

    return HomeDataClient(
      retrievePopularMangas: {
        @Dependency(\.calendar) var calendar
        @Dependency(\.date) var date

        let lastMonth = calendar.date(
          byAdding: .month,
          value: -1,
          to: date(),
          wrappingComponents: false
        )
        let popularMangas = try await mangaAPI.listMangas(
          request: .init(
            limit: 10,
            createdAtSince: lastMonth,
            order: .init(followedCount: .descending)
          )
        )
        try await mangaRepository.importMangas(popularMangas.data)
        return try await storeCoordinator.mangas(for: popularMangas.data.map(\.id))
      },
      retrieveLatestChapters: {
        let latestChapters = try await chapterAPI.listChapters(
          request: .init(
            limit: 64,
            order: .init(readableAt: .descending)
          )
        )

        let mangaIDs = latestChapters.data
          .compactMap { $0.relationship(MangaRelationship.self) }
          .map(\.id)

        let mangas = try await mangaAPI.listMangas(
          request: .init(ids: mangaIDs)
        )
        try await mangaRepository.importMangas(mangas.data)
        try await chapterRepository.importChapters(chapters: latestChapters.data)

        return try await storeCoordinator.chapters(for: latestChapters.data.map(\.id))
      },
      retrieveRecentlyAddedMangas: {
        let recentlyAddedMangas = try await mangaAPI.listMangas(
          request: .init(
            limit: 15,
            order: .init(createdAt: .descending)
          )
        )
        try await mangaRepository.importMangas(recentlyAddedMangas.data)
        return try await storeCoordinator.mangas(for: recentlyAddedMangas.data.map(\.id))
      }
    )
  }

  static let testValue = HomeDataClient()

  @ModelActor
  actor StoreCoordinator {
    @Dependency(\.mangaRepository) var mangaRepository
    @Dependency(\.chapterRepository) var chapterRepository

    func mangas(for ids: [UUID]) throws -> IdentifiedArrayOf<Manga> {
      let mangas: [Manga] = try mangaRepository.fetchMangas(ids: ids, context: modelContext)
        .ordered(by: ids, id: \.mangaID)
        .compactMap {
          guard let author = $0.author else { return nil }

          return Manga(
            id: $0.mangaID,
            name: $0.title,
            description: $0.overview,
            coverImageURL: $0.coverThumbnailImageURL(for: .medium),
            authorName: author.name,
            artistName: $0.artist?.name
          )
        }

      return IdentifiedArray(uniqueElements: mangas)
    }

    func chapters(for ids: [UUID]) throws -> IdentifiedArrayOf<Chapter> {
      let dictionary: OrderedDictionary<UUID, Chapter> = try chapterRepository
        .fetchChapters(ids: ids, context: modelContext)
        .ordered(by: ids, id: \.chapterID)
        .reduce(into: [:]) { result, chapter in
          guard let manga = chapter.manga, result[manga.mangaID] == nil else {
            return
          }

          let item = Chapter(
            id: chapter.chapterID,
            title: chapter.title,
            chapter: chapter.chapter,
            volume: chapter.volume,
            mangaTitle: manga.title,
            coverImageURL: manga.coverThumbnailImageURL(for: .small)
          )
          result[manga.mangaID] = item
        }

      return IdentifiedArray(uniqueElements: dictionary.values)
    }
  }
}

extension DependencyValues {
  var homeData: HomeDataClient {
    get { self[HomeDataClient.self] }
    set { self[HomeDataClient.self] = newValue }
  }
}

// MARK: - Helpers

private extension Collection {
  /// Returns a sorted copy of the collection, in the order of the identifiers passed in.
  func ordered<ID: Hashable>(
    by ids: some Collection<ID>,
    id: KeyPath<Element, ID>
  ) -> [Element] {
    let elements = IdentifiedArray(self, id: id) { $1 }
    return ids.compactMap { elements[id: $0] }
  }
}
