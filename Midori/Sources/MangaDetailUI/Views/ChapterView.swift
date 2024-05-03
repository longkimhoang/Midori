//
//  ChapterView.swift
//
//
//  Created by Long Kim on 3/5/24.
//

import Common
import MangaDetailCore
import SwiftUI

struct ChapterView: View {
  let chapter: Chapter

  var body: some View {
    VStack(alignment: .leading) {
      Text(chapterName)
        .fontWeight(.medium)

      ScanlatorGroupLabel(name: chapter.scanlatorGroup)

      Text(chapter.readableAt, format: .relative(presentation: .numeric, unitsStyle: .narrow))
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .lineLimit(1)
  }

  private var chapterName: String {
    let localizedChapter = chapter.chapter.map {
      String(localized: "Ch. \($0)", bundle: .module)
    }

    let name = [localizedChapter, chapter.title].compacted()
      .joined(separator: " - ")
    return name.isEmpty ? String(localized: "Oneshot", bundle: .module) : name
  }
}
