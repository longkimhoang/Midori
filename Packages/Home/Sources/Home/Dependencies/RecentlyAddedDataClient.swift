//
//  RecentlyAddedDataClient.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Dependencies
import DependenciesMacros
import Domain
import Foundation
import IdentifiedCollections
import MangaList
import SwiftData

@DependencyClient
struct RecentlyAddedDataClient: Sendable {
  var fetchRecentMangasFromStorage: @Sendable () async throws -> IdentifiedArrayOf<MangaList.Manga>
}

extension RecentlyAddedDataClient: DependencyKey {
  static var liveValue: RecentlyAddedDataClient {
    @Dependency(\.modelContainer) var modelContainer
    let storeCoordinator = StoreCoordinator(modelContainer: modelContainer)

    return RecentlyAddedDataClient(
      fetchRecentMangasFromStorage: {
        try await storeCoordinator.fetchRecentMangas()
      }
    )
  }

  static let testValue = RecentlyAddedDataClient()

  @ModelActor
  actor StoreCoordinator {
    @Dependency(\.mangaRepository) private var mangaRepository

    func fetchRecentMangas() throws -> IdentifiedArrayOf<MangaList.Manga> {
      var descriptor = FetchDescriptor.recentlyAddedMangas()
      descriptor.relationshipKeyPathsForPrefetching = [\.author, \.artist]
      let mangas = try mangaRepository.fetchMangas(
        descriptor: descriptor,
        context: modelContext
      )

      return IdentifiedArray(
        uniqueElements: mangas.compactMap { manga in
          guard let author = manga.author else {
            return nil
          }

          return .init(
            id: manga.mangaID,
            title: manga.title,
            description: manga.overview,
            authorName: author.name,
            artistName: manga.artist?.name,
            coverImageURL: manga.coverThumbnailImageURL(for: .small)
          )
        }
      )
    }
  }
}

extension DependencyValues {
  var recentlyAddedData: RecentlyAddedDataClient {
    get { self[RecentlyAddedDataClient.self] }
    set { self[RecentlyAddedDataClient.self] = newValue }
  }
}
