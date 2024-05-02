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
      guard let manga = try modelContext.fetch(mangaDescriptor).first,
            let author = manga.author
      else {
        return nil
      }

      let chaptersDescriptor = FetchDescriptor.chaptersForManga(mangaID: mangaID)
      let chapters: [MangaFeed.Chapter] = try modelContext
        .fetch(chaptersDescriptor)
        .compactMap { chapter in
          guard let scanlationGroup = chapter.scanlationGroup else {
            return nil
          }

          return MangaFeed.Chapter(
            id: chapter.chapterID,
            chapter: chapter.chapter,
            volume: chapter.volume,
            readableAt: chapter.readableAt,
            scanlatorGroup: scanlationGroup.name
          )
        }

      let info = MangaFeed.MangaInfo(
        title: manga.title,
        description: manga.overview,
        authorName: author.name,
        artistName: manga.artist?.name,
        coverImageURL: manga.coverThumbnailImageURL(for: .medium)
      )

      return MangaFeed(
        info: info,
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
