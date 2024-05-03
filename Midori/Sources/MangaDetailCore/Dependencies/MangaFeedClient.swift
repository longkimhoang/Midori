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
  var fetchChapters: @Sendable (
    _ mangaID: UUID,
    _ offset: Int?
  ) async throws -> IdentifiedArrayOf<Chapter>
}

extension MangaFeedClient: DependencyKey {
  static var liveValue: MangaFeedClient {
    @Dependency(\.mangaAPI) var mangaAPI
    @Dependency(\.chapterRepository) var chapterRepository
    @Dependency(\.modelContainer) var modelContainer
    let storeCoordinator = StoreCoordinator(modelContainer: modelContainer)

    return MangaFeedClient(
      fetchFeedFromStorage: { mangaID in
        try await storeCoordinator.fetchMangaFeed(mangaID: mangaID)
      },
      fetchChapters: { mangaID, offset in
        let feed = try await mangaAPI.mangaFeed(request: .init(mangaID: mangaID))
        try await chapterRepository.importChapters(chapters: feed.data)
        return try await storeCoordinator.fetchChapters(mangaID: mangaID, offset: offset)
      }
    )
  }

  static let testValue = MangaFeedClient()

  @ModelActor
  actor StoreCoordinator {
    func fetchMangaFeed(mangaID: UUID) throws -> MangaFeed? {
      let mangaDescriptor = FetchDescriptor.mangaByID(mangaID)
      guard let mangaModel = try modelContext.fetch(mangaDescriptor).first,
            let author = mangaModel.author
      else {
        return nil
      }

      let manga = Manga(
        id: mangaModel.mangaID,
        title: mangaModel.title,
        description: mangaModel.overview,
        authorName: author.name,
        artistName: mangaModel.artist?.name,
        coverImageURL: mangaModel.coverThumbnailImageURL(for: .medium)
      )

      return try MangaFeed(
        manga: manga,
        chapters: fetchChapters(mangaID: mangaID)
      )
    }

    func fetchChapters(
      mangaID: UUID,
      offset: Int? = nil
    ) throws -> IdentifiedArrayOf<Chapter> {
      let chaptersDescriptor = FetchDescriptor.chaptersForManga(mangaID: mangaID, offset: offset)
      let chapters: [Chapter] = try modelContext
        .fetch(chaptersDescriptor)
        .compactMap { chapter in
          guard let scanlationGroup = chapter.scanlationGroup else {
            return nil
          }

          return Chapter(
            id: chapter.chapterID,
            title: chapter.title,
            chapter: chapter.chapter,
            volume: chapter.volume,
            readableAt: chapter.readableAt,
            scanlatorGroup: scanlationGroup.name
          )
        }

      return IdentifiedArray(uniqueElements: chapters)
    }
  }
}

extension DependencyValues {
  var mangaFeed: MangaFeedClient {
    get { self[MangaFeedClient.self] }
    set { self[MangaFeedClient.self] = newValue }
  }
}
