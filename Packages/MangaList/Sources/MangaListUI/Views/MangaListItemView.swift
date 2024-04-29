//
//  MangaListItemView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import Algorithms
import MangaList
import SwiftUI

struct MangaListItemView: View {
  @Environment(\.locale) private var locale

  let manga: Manga
  let coverImage: Image?

  init(manga: Manga, coverImage: Image? = nil) {
    self.manga = manga
    self.coverImage = coverImage
  }

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Rectangle()
        .fill(.fill.tertiary)
        .overlay {
          coverImage?.resizable()
            .aspectRatio(contentMode: .fill)
        }
        .frame(width: 60, height: 60 / 0.7)
        .clipShape(.rect(cornerRadius: 8))

      VStack(alignment: .leading) {
        Text(manga.title.localized(for: locale))
          .font(.headline)
          .lineLimit(1)

        if !subtitle.isEmpty {
          Text(subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        if let description = manga.description?.localized(for: locale) {
          Text(description)
        }

        Spacer()
      }
      .lineLimit(3)

      Spacer()
    }
  }

  private var subtitle: String {
    [manga.authorName, manga.artistName].compacted().formatted(.list(type: .and, width: .narrow))
  }
}

struct ListItemBackgroundStyle: ShapeStyle {
  func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
    #if targetEnvironment(macCatalyst)
    if environment.colorScheme == .dark {
      AnyShapeStyle(.background.tertiary)
    } else {
      AnyShapeStyle(.background.secondary)
    }
    #else
    .background.secondary
    #endif
  }
}
