//
//  MangaStore.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import Algorithms
import APIModels
import Database
import SwiftData

@ModelActor
actor MangaStore {
  private static let chunkSize = 100

  func importMangas(_ mangas: some Collection<APIModels.Manga>) throws {
    let chunks = mangas.chunks(ofCount: Self.chunkSize)
    for chunk in chunks {
      for model in chunk {
        let manga = Manga(
          mangaID: model.id,
          title: model.attributes.title.value,
          description: model.attributes.description?.value,
          coverImageURL: model.coverImageURL,
          createdAt: model.attributes.createdAt
        )

        if let artist = model.artist {
          manga.artist = Artist(
            artistID: artist.id,
            name: artist.attributes.name,
            imageURL: artist.attributes.imageURL
          )
        }

        if let author = model.author {
          manga.author = Author(
            authorID: author.id,
            name: author.attributes.name,
            imageURL: author.attributes.imageURL
          )
        }

        modelContext.insert(manga)
      }

      try modelContext.save()
    }
  }
}
