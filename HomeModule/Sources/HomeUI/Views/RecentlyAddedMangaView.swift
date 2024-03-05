//
//  RecentlyAddedMangaView.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import Foundation
import Persistence
import SDWebImageSwiftUI
import SwiftUI

struct RecentlyAddedMangaView: View {
  @ObservedObject var manga: Manga

  var body: some View {
    VStack(alignment: .leading) {
      WebImage(url: coverThumbnailURL)
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 128, height: 128 / 0.7)
        .clipShape(.rect(cornerRadius: 8))

      Text(manga.title)
        .font(.headline)
        .lineLimit(2)
    }
  }

  private var coverThumbnailURL: URL? {
    guard let coverImageURL = manga.coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".256.jpg")
  }
}
