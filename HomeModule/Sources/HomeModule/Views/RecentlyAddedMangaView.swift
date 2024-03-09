//
//  RecentlyAddedMangaView.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import Database
import Foundation
import SwiftUI

struct RecentlyAddedMangaView: View {
  let manga: Manga
  let coverThumbnailImage: Image?

  var body: some View {
    VStack(alignment: .leading) {
      Rectangle()
        .fill(.fill.tertiary)
        .overlay {
          coverThumbnailImage?
            .resizable()
            .aspectRatio(contentMode: .fill)
        }
        .frame(width: 128, height: 128 / 0.7)
        .clipShape(.rect(cornerRadius: 8))
        .overlay {
          RoundedRectangle(cornerRadius: 8)
            .stroke(.fill)
        }

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
