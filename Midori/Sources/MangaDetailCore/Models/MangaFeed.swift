//
//  MangaFeed.swift
//
//
//  Created by Long Kim on 1/5/24.
//

import Domain
import Foundation
import IdentifiedCollections
import OrderedCollections

public struct MangaFeed: Equatable, Sendable {
  public let manga: Manga
  public var chapters: IdentifiedArrayOf<Chapter>
}

public extension MangaFeed {
  /// Groups the chapter IDs by volume.
  ///
  /// The `nil` key denotes that the chapters does not have a volume. This usually means that the
  /// chapter has not yet been part of a volume, and thus are ordered at the front.
  var chapterIDsGroupedByVolume: OrderedDictionary<String?, [Chapter.ID]> {
    chapters.reduce(into: [:]) { result, chapter in
      let volume = chapter.volume
      let chapterID = chapter.id

      result.updateValue(
        forKey: volume,
        default: []
      ) { $0.append(chapterID) }

      if let chapterIDsWithoutVolume = result.removeValue(forKey: nil) {
        result.updateValue(chapterIDsWithoutVolume, forKey: nil, insertingAt: 0)
      }
    }
  }
}
