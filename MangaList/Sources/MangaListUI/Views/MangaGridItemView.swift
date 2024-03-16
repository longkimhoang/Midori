//
//  MangaGridItemView.swift
//
//
//  Created by Long Kim on 16/3/24.
//

import CommonUI
import Database
import SwiftUI

struct MangaGridItemView: View {
  let manga: Manga
  let coverImage: Image?

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        MangaCoverImage(
          image: coverImage,
          width: geometry.size.width,
          aspectRatio: geometry.size.width / geometry.size.height
        )

        HStack {
          Text(manga.title)
            .font(.headline)

          Spacer()
        }
        .padding()
        .lineLimit(2)
        .multilineTextAlignment(.leading)
      }
    }
  }
}
