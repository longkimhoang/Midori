//
//  MangaListItemView.swift
//
//
//  Created by Long Kim on 15/3/24.
//

import CommonUI
import Database
import SwiftUI

struct MangaListItemView: View {
  let manga: Manga
  let coverImage: Image?

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      MangaCoverImage(image: coverImage, width: 60)

      VStack(alignment: .leading) {
        Text(manga.title)
          .font(.headline)
          .lineLimit(1)

        if let author = manga.author {
          Text(author.name)
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

  private var backgroundColor: some ShapeStyle {
    #if os(iOS)
    .background.secondary
    #else
    .fill.tertiary
    #endif
  }
}

private struct CellSizingModifier: ViewModifier {
  func body(content: Content) -> some View {
    VStack(alignment: .leading) {
      content
      Spacer()
    }
  }
}
