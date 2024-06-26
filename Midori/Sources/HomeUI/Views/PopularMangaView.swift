//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 27/4/24.
//

import Algorithms
import HomeCore
import SwiftUI

struct PopularMangaView: View {
  @Environment(\.locale) private var locale

  let manga: Manga
  let coverImage: Image?

  init(manga: Manga, coverImage: Image? = nil) {
    self.manga = manga
    self.coverImage = coverImage
  }

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        coverImage?.resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: geometry.size.height)
      }

      GeometryReader { geometry in
        HStack(alignment: .top, spacing: 16) {
          Rectangle()
            .fill(.fill.tertiary)
            .overlay {
              coverImage?.resizable()
                .aspectRatio(contentMode: .fill)
            }
            .frame(width: geometry.size.height * 0.7, height: geometry.size.height)
            .clipShape(.rect(cornerRadius: 8))
            .shadow(
              color: Color(white: 0, opacity: 0.2),
              radius: 8,
              y: 12
            )

          VStack(alignment: .leading) {
            Text(manga.name.localized(for: locale))
              .font(.title2)
              .lineLimit(3)

            Text(subtitleText)
              .font(.title3)
              .foregroundStyle(.secondary)
              .lineLimit(2)
          }
        }
      }
      .padding()
      .background(.regularMaterial)
    }
    .clipShape(.rect(cornerRadius: 16))
  }

  private var subtitleText: String {
    [manga.authorName, manga.artistName].compacted().formatted(.list(type: .and, width: .narrow))
  }
}

#Preview("Without Image", traits: .sizeThatFitsLayout) {
  PopularMangaView(
    manga: .init(
      id: UUID(),
      name: "Test manga",
      description: "Test description",
      authorName: "An author"
    )
  )
  .padding()
  .frame(height: 200)
}

#Preview("With Image", traits: .sizeThatFitsLayout) {
  PopularMangaView(
    manga: .init(
      id: UUID(),
      name: "Test manga",
      description: "Test description",
      authorName: "An author"
    ),
    coverImage: Image(.previewCover)
  )
  .padding()
  .frame(height: 200)
}
