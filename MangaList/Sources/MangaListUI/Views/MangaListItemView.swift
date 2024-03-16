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
          .lineLimit(2)

        if let author = manga.author {
          Text(author.name)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        if let description = manga.mangaDescription {
          Text(description)
            .lineLimit(3)
        }
      }

      Spacer()
    }
    #if os(macOS)
    .modifier(CellSizingModifier())
    #endif
    .padding()
    .background(backgroundColor, in: .rect(cornerRadius: 16))
  }

  private var backgroundColor: some ShapeStyle {
    #if os(iOS)
    Color(uiColor: .secondarySystemGroupedBackground)
    #else
    .fill.tertiary
    #endif
  }
}

#if os(macOS)
/// On macOS we don't have `uniformAcrossSiblings` so we have to make do with
/// absolute sizing. Therefore we need to stretch the content to the provided height.
private struct CellSizingModifier: ViewModifier {
  func body(content: Content) -> some View {
    VStack(alignment: .leading) {
      content
      Spacer()
    }
  }
}
#endif
