//
//  LatestChaptersClient.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import APIClients
import APIModels
import Database
import Dependencies
import DependenciesMacros
import Domain
import Foundation
import OrderedCollections
import SwiftData

@DependencyClient
struct LatestChaptersClient {
  var fetch: () async throws -> [Database.Chapter]
}

extension LatestChaptersClient: DependencyKey {
  static var liveValue: LatestChaptersClient {
    @Dependency(\.mangaAPI) var mangaAPI
    @Dependency(\.mangaStore) var mangaStore
    @Dependency(\.chapterAPI) var chapterAPI
    @Dependency(\.chapterStore) var chapterStore

    return LatestChaptersClient(
      fetch: {
        let latestChapters = try await chapterAPI.listChapters(
          parameters: ListChaptersParameters(
            limit: 64,
            includes: [.scanlationGroup],
            order: ListChaptersSortOrder(readableAt: .descending)
          )
        )

        let chapterByMangas: OrderedDictionary<UUID, APIModels.Chapter> = latestChapters.chapters
          .reduce(into: [:]) { dict, chapter in
            guard let mangaID = chapter.relationships.first(MangaRelationship.self)?.id, dict[mangaID] == nil else {
              return
            }

            dict[mangaID] = chapter
          }

        let latestMangas = try await mangaAPI.listMangas(
          parameters: ListMangasParameters(
            limit: 100,
            ids: chapterByMangas.keys.map { $0.uuidString.lowercased() },
            includes: [.cover]
          )
        )

        try await mangaStore.import(mangas: latestMangas.mangas)
        try await chapterStore.import(chapters: latestChapters.chapters)

        let chapterIDs = chapterByMangas.values.map(\.id)
        return try await chapterStore.queryByIDs(chapterIDs) {
          $0.sortBy = [SortDescriptor(\.readableAt, order: .reverse)]
          $0.relationshipKeyPathsForPrefetching = [\.manga]
        }
      }
    )
  }
}

extension DependencyValues {
  var latestChapters: LatestChaptersClient {
    get { self[LatestChaptersClient.self] }
    set { self[LatestChaptersClient.self] = newValue }
  }
}
