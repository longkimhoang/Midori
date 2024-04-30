//
//  MangaGridItemView.swift
//
//
//  Created by Long Kim on 30/4/24.
//

import MangaListCore
import SwiftUI

struct MangaGridItemView: View {
  @Environment(\.locale) private var locale

  let manga: Manga
  let coverImage: Image?

  var body: some View {
    VStack {
      Spacer()

      HStack {
        Text(manga.title.localized(for: locale))
          .font(.headline)
          .lineLimit(2, reservesSpace: true)
          .multilineTextAlignment(.leading)

        Spacer()
      }
      .padding()
      .background(.thinMaterial)
    }
    .background {
      coverImage?.resizable()
        .aspectRatio(contentMode: .fill)
    }
    .background(.fill.tertiary)
    .clipShape(.rect(cornerRadius: 16))
  }
}
