//
//  Chapter+FetchDescriptors.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import Foundation
import SwiftData

public extension FetchDescriptor where T == Chapter {
  /// A fetch descriptor for chapters belonging to a manga.
  static func chaptersForManga(
    mangaID: UUID,
    limit: Int? = 100,
    offset: Int? = nil
  ) -> FetchDescriptor<Chapter> {
    var descriptor = FetchDescriptor<Chapter>()
    descriptor.predicate = #Predicate { $0.manga?.mangaID == mangaID }
    descriptor.sortBy = [
      SortDescriptor(\.volume, order: .reverse),
      SortDescriptor(\.chapter, order: .reverse),
      SortDescriptor(\.readableAt, order: .reverse),
      SortDescriptor(\.title),
    ]
    descriptor.fetchLimit = limit
    descriptor.fetchOffset = offset

    return descriptor
  }
}
