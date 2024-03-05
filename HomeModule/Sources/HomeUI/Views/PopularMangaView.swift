//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Foundation
import Persistence
import SDWebImageSwiftUI
import SwiftUI

struct PopularMangaView: View {
  @ObservedObject var manga: Manga

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        WebImage(url: coverThumbnailURL)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: geometry.size.height)
      }

      GeometryReader { geometry in
        HStack(alignment: .top, spacing: 16) {
          WebImage(url: coverThumbnailURL) { imagePhase in
            Group {
              switch imagePhase {
              case let .success(image):
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              default:
                Rectangle().fill(.fill.secondary)
              }
            }
            .frame(
              width: geometry.size.height * 0.7,
              height: geometry.size.height
            )
          }
          .clipShape(.rect(cornerRadius: 8))

          VStack(alignment: .leading) {
            Text(manga.title)
              .font(.title2)
              .lineLimit(3)

            Text(manga.artist.name)
              .font(.title3)
              .foregroundStyle(.secondary)
          }

          Spacer()
        }
      }
      .padding()
      .background(.regularMaterial)
    }
    .clipShape(.rect(cornerRadius: 16))
  }

  private var coverThumbnailURL: URL? {
    guard let coverImageURL = manga.coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".256.jpg")
  }
}
