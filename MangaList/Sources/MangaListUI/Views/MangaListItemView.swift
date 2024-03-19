//
//  MangaListItemView.swift
//
//
//  Created by Long Kim on 15/3/24.
//

import Algorithms
import CommonUI
import Database
import SwiftUI

struct MangaListItemView: View {
  @Environment(\.colorScheme) private var colorScheme
  let manga: Manga
  let coverImage: Image?

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      MangaCoverImage(image: coverImage, width: 60)

      VStack(alignment: .leading) {
        Text(manga.title)
          .font(.headline)
          .lineLimit(1)

        if !subtitle.isEmpty {
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        if let description = manga.mangaDescription {
          Text(description)
            .lineLimit(3)
        }

        Spacer()
      }

      Spacer()
    }
    .padding()
    .background(backgroundColor, in: .rect(cornerRadius: 16))
  }

  private var subtitle: String {
    [manga.author?.name, manga.artist?.name].compacted().uniqued().joined(separator: ", ")
  }

  private var backgroundColor: AnyShapeStyle {
    #if targetEnvironment(macCatalyst)
    switch colorScheme {
    case .dark: AnyShapeStyle(.background.tertiary)
    default: AnyShapeStyle(.background.secondary)
    }
    #else
    AnyShapeStyle(.background.secondary)
    #endif
  }
}
