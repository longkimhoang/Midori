//
//  RecentlyAddedMangaView.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import CommonUI
import Database
import Foundation
import SwiftUI

struct RecentlyAddedMangaView: View {
  let manga: Manga
  let coverThumbnailImage: Image?

  var body: some View {
    VStack(alignment: .leading) {
      MangaCoverImage(image: coverThumbnailImage, width: 128)

      Text(manga.title)
        .font(.headline)
        .lineLimit(2, reservesSpace: true)
    }
  }

  private var coverThumbnailURL: URL? {
    guard let coverImageURL = manga.coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".256.jpg")
  }
}
