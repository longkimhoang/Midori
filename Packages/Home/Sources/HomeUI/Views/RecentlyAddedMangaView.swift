//
//  RecentlyAddedMangaView.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Home
import SwiftUI

struct RecentlyAddedMangaView: View {
  @Environment(\.locale) private var locale

  let manga: Manga
  let coverImage: Image?

  init(manga: Manga, coverImage: Image? = nil) {
    self.manga = manga
    self.coverImage = coverImage
  }

  var body: some View {
    VStack(alignment: .leading) {
      Rectangle()
        .fill(.fill.tertiary)
        .overlay {
          coverImage?.resizable()
            .aspectRatio(contentMode: .fill)
        }
        .frame(width: 128, height: 128 / 0.7)
        .clipShape(.rect(cornerRadius: 8))

      Text(manga.name.localized(for: locale))
        .font(.headline)
        .lineLimit(2, reservesSpace: true)
    }
  }
}
