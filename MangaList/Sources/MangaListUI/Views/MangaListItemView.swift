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

        if let author = manga.author {
          Text(author.name)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }

      Spacer()
    }
    .padding()
    .background(.fill.quaternary, in: .rect(cornerRadius: 16))
  }
}
