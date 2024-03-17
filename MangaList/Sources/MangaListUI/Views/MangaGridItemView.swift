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
  @Environment(\.pixelLength) var pixelLength
  let manga: Manga
  let coverImage: Image?

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        coverImage?.resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: geometry.size.height)

        HStack {
          Text(manga.title)
            .font(.headline)
            .lineLimit(2, reservesSpace: true)
            .multilineTextAlignment(.leading)

          Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .background(.thinMaterial)
      }
    }
    .clipShape(.rect(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(.separator, lineWidth: pixelLength)
    }
  }
}
