//
//  LatestChapterView.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Algorithms
import CommonUI
import Database
import Foundation
import SwiftUI

struct LatestChapterView: View {
  let chapter: Chapter
  let coverThumbnailImage: Image?

  var body: some View {
    if let manga = chapter.manga {
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          MangaCoverImage(image: coverThumbnailImage, width: 60)

          VStack(alignment: .leading) {
            Text(manga.title)
              .font(.headline)

            Text(chapterName)
              .font(.subheadline)

            Text(chapter.readableAt, format: .relative(presentation: .numeric, unitsStyle: .narrow))
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
          .lineLimit(1)
          #if os(iOS)
          .anchorPreference(key: ContentStackLeadingAnchorPreference.self, value: .leading) { $0 }
          #endif

          Spacer()
        }
      }
      .padding([.vertical, .trailing])
      #if os(iOS)
        .overlayPreferenceValue(ContentStackLeadingAnchorPreference.self) { preference in
          GeometryReader { geometry in
            if let preference {
              VStack {
                Spacer()
                Divider()
              }
              .padding(.trailing)
              .padding(.leading, geometry[preference].x)
            }
          }
        }
      #endif
    }
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

#if os(iOS)
private struct ContentStackLeadingAnchorPreference: PreferenceKey {
  typealias Value = Anchor<CGPoint>?

  static var defaultValue: Value = nil

  static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
    value = nextValue()
  }
}
#endif
