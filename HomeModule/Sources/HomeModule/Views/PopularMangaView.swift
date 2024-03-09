//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Database
import Foundation
import SwiftUI

struct PopularMangaView: View {
  let manga: Manga
  let coverThumbnailImage: Image?

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        coverThumbnailImage?.resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: geometry.size.height)
      }

      GeometryReader { geometry in
        HStack(alignment: .top, spacing: 16) {
          Rectangle()
            .fill(.fill.tertiary)
            .overlay {
              coverThumbnailImage?
                .resizable()
                .aspectRatio(contentMode: .fill)
            }
            .frame(
              width: geometry.size.height * 0.7,
              height: geometry.size.height
            )
            .clipShape(.rect(cornerRadius: 8))

          VStack(alignment: .leading) {
            Text(manga.title)
              .font(.title2)
              .lineLimit(3)

            if let artist = manga.artist {
              Text(artist.name)
                .font(.title3)
                .foregroundStyle(.secondary)
            }
          }

          Spacer()
        }
      }
      .padding()
      .background(.regularMaterial)
    }
    .clipShape(.rect(cornerRadius: 16))
  }
}
