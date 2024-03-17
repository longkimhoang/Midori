//
//  ChapterStore.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Algorithms
import APIModels
import Database
import Foundation
import IdentifiedCollections
import SwiftData

@ModelActor
actor ChapterStore {
  private static let chunkSize = 100

  func importChapters(_ chapters: some Collection<APIModels.Chapter>) throws {
    let chunks = chapters.chunks(ofCount: Self.chunkSize)
    for chunk in chunks {
      let mangaIDs = chunk.compactMap(\.mangaID)
      var mangasFetchDescriptor = FetchDescriptor(predicate: #Predicate<Database.Manga> { manga in
        mangaIDs.contains(manga.mangaID)
      })
      mangasFetchDescriptor.propertiesToFetch = [\.mangaID]
      let mangas = try IdentifiedArray(
        uniqueElements: modelContext.fetch(mangasFetchDescriptor),
        id: \.mangaID
      )

      for model in chunk {
        let chapter = Chapter(
          chapterID: model.id,
          volume: model.attributes.volume,
          title: model.attributes.title,
          chapter: model.attributes.chapter,
          readableAt: model.attributes.readableAt
        )

        if let mangaID = model.mangaID, let manga = mangas[id: mangaID] {
          chapter.manga = manga
        }

        modelContext.insert(chapter)
      }

      try modelContext.save()
    }
  }
}

private extension APIModels.Chapter {
  var mangaID: UUID? {
    relationships.first(MangaRelationship.self).map(\.id)
  }
}
