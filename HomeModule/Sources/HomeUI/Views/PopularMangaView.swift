//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Foundation
import Persistence
import SwiftUI
import SDWebImageSwiftUI

struct PopularMangaView: View {
  let manga: Manga

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      WebImage(url: coverThumbnailURL) { imagePhase in
        switch imagePhase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 140, height: 200, alignment: .center)
        default:
          Rectangle().fill(.fill.secondary)
            .frame(width: 140, height: 200, alignment: .center)
        }
      }
      .clipShape(.rect(cornerRadius: 8))

      VStack(alignment: .leading) {
        Text(manga.title)
          .font(.title)
          .lineLimit(3)

        Text(manga.artist.name)
          .font(.title2)
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
  }

  private var coverThumbnailURL: URL? {
    guard let coverImageURL = manga.coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".256.jpg")
  }
}
