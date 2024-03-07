//
//  LatestChapterView.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Foundation
import Persistence
import SwiftUI

struct LatestChapterView: View {
  @ObservedObject var chapter: Chapter
  let coverThumbnailImage: Image?

  var body: some View {
    HStack(alignment: .top) {
      Rectangle()
        .fill(.fill.tertiary)
        .overlay {
          coverThumbnailImage?
            .resizable()
            .aspectRatio(contentMode: .fill)
        }
        .frame(width: 60, height: 60 / 0.7)
        .clipShape(.rect(cornerRadius: 8))

      VStack(alignment: .leading) {
        Text(chapter.manga.title)
          .font(.headline)
          .lineLimit(2)

        Text(chapter.name)
          .font(.subheadline)
      }

      Spacer()
    }
  }
}
