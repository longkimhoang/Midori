//
//  MangaFeedClient.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import Dependencies
import DependenciesMacros
import Domain
import Foundation
import IdentifiedCollections
import SwiftData

@DependencyClient
struct MangaFeedClient: Sendable {
  var fetchFeedFromStorage: @Sendable (_ mangaID: UUID) async throws -> MangaFeed?
}

extension MangaFeedClient: DependencyKey {
  static var liveValue: MangaFeedClient {
    @Dependency(\.modelContainer) var modelContainer
    let storeCoordinator = StoreCoordinator(modelContainer: modelContainer)

    return MangaFeedClient(
      fetchFeedFromStorage: { mangaID in
        try await storeCoordinator.fetchMangaFeed(mangaID: mangaID)
      }
    )
  }

  static let testValue = MangaFeedClient()

  @ModelActor
  actor StoreCoordinator {
    func fetchMangaFeed(mangaID: UUID) throws -> MangaFeed? {
      let mangaDescriptor = FetchDescriptor.mangaByID(mangaID)
      guard let manga = try modelContext.fetch(mangaDescriptor).first else {
        return nil
      }

      let chaptersDescriptor = FetchDescriptor.chaptersForManga(mangaID: mangaID)
      let chapters = try modelContext.fetch(chaptersDescriptor).map { chapter in
        MangaFeed.Chapter(
          id: chapter.chapterID,
          chapter: chapter.chapter,
          volume: chapter.volume,
          readableAt: chapter.readableAt,
          scanlatorGroup: "<no scanlator>"
        )
      }

      return MangaFeed(
        title: manga.title,
        chapters: IdentifiedArray(
          uniqueElements: chapters
        )
      )
    }
  }
}

extension DependencyValues {
  var mangaFeed: MangaFeedClient {
    get { self[MangaFeedClient.self] }
    set { self[MangaFeedClient.self] = newValue }
  }
}
