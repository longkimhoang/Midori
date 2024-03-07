//
//  LatestChapterView.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Algorithms
import Foundation
import Persistence
import SwiftUI

struct LatestChapterView: View {
  @ObservedObject var chapter: Chapter
  let coverThumbnailImage: Image?

  var body: some View {
    if let manga = chapter.manga {
      VStack(alignment: .leading) {
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
            .overlay {
              RoundedRectangle(cornerRadius: 8)
                .stroke(.fill)
            }

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
          .anchorPreference(key: ContentStackLeadingAnchorPreference.self, value: .leading) { $0 }

          Spacer()
        }
      }
      .padding([.vertical, .trailing])
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
    }
  }

  private var chapterName: String {
    let localizedChapter = chapter.chapter.map {
      String(localized: "Ch. \($0)", comment: "Shortform for chapter")
    }

    let localizedVolume = chapter.volume.map {
      String(localized: "Vol. \($0)", comment: "Shortform for volume")
    }

    let name = [localizedVolume, localizedChapter, chapter.title].compacted()
      .joined(separator: " - ")
    return name.isEmpty ? String(localized: "Oneshot") : name
  }
}

private struct ContentStackLeadingAnchorPreference: PreferenceKey {
  typealias Value = Anchor<CGPoint>?

  static var defaultValue: Value = nil

  static func reduce(value: inout Anchor<CGPoint>?, nextValue: () -> Anchor<CGPoint>?) {
    value = nextValue()
  }
}
