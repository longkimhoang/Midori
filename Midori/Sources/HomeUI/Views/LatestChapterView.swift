//
//  LatestChapterView.swift
//
//
//  Created by Long Kim on 27/4/24.
//

import Algorithms
import HomeCore
import SwiftUI

struct LatestChapterView: View {
  @Environment(\.locale) private var locale

  let chapter: Chapter
  let coverImage: Image?

  init(chapter: Chapter, coverImage: Image? = nil) {
    self.chapter = chapter
    self.coverImage = coverImage
  }

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        Rectangle()
          .fill(.fill.tertiary)
          .overlay {
            coverImage?.resizable()
              .aspectRatio(contentMode: .fill)
          }
          .frame(width: 60, height: 60 / 0.7)
          .clipShape(.rect(cornerRadius: 8))

        HStack(alignment: .top) {
          VStack(alignment: .leading) {
            Text(chapter.mangaTitle.localized(for: locale))
              .font(.headline)

            Text(chapterName)
              .font(.subheadline)

            Spacer()
          }
          .lineLimit(1)
          .frame(height: 60 / 0.7)
          .padding(.bottom, 8)

          Spacer()
        }
        .overlay(alignment: .bottom) {
          VStack {
            Divider()
          }
        }
      }
    }
    .padding([.top, .trailing])
  }

  private var chapterName: String {
    let localizedChapter = chapter.chapter.map {
      String(localized: "Ch. \($0)", bundle: .module, comment: "Shortform for chapter")
    }

    let localizedVolume = chapter.volume.map {
      String(localized: "Vol. \($0)", bundle: .module, comment: "Shortform for volume")
    }

    let name = [localizedVolume, localizedChapter, chapter.title].compacted()
      .joined(separator: " - ")
    return name.isEmpty ? String(localized: "Oneshot", bundle: .module) : name
  }
}

#Preview("Normal", traits: .sizeThatFitsLayout) {
  LatestChapterView(
    chapter: .init(
      id: UUID(),
      title: "Test chapter",
      chapter: "1",
      volume: "1",
      mangaTitle: "Test manga",
      coverImageURL: nil,
      mangaID: UUID()
    ),
    coverImage: Image(.previewCover)
  )
  .frame(height: 100)
  .padding()
}

#Preview("Oneshot", traits: .sizeThatFitsLayout) {
  LatestChapterView(
    chapter: .init(
      id: UUID(),
      title: nil,
      chapter: nil,
      volume: nil,
      mangaTitle: "Test manga",
      coverImageURL: nil,
      mangaID: UUID()
    ),
    coverImage: Image(.previewCover)
  )
  .frame(height: 100)
  .padding()
}
