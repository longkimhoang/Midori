//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Foundation
import Persistence
import SwiftUI

struct PopularMangaView: View {
  let manga: Manga

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Color.secondary
        .aspectRatio(1 / 1.42, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 8))

      VStack(alignment: .leading) {
        Text(manga.title)
          .font(.headline)
          .lineLimit(4)

        Text(manga.artist.name)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
  }
}
