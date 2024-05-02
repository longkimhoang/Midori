//
//  Manga+FetchDescriptors.swift
//
//
//  Created by Long Kim on 28/4/24.
//

import Foundation
import SwiftData

public extension FetchDescriptor where T == Manga {
  /// A fetch descriptor for recently added mangas.
  static func recentlyAddedMangas(limit: Int = 100) -> FetchDescriptor<Manga> {
    var descriptor = FetchDescriptor<Manga>()
    descriptor.predicate = #Predicate { $0.author != nil }
    descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
    descriptor.fetchLimit = limit

    return descriptor
  }

  /// A fetch descriptor for a single manga by its ID.
  static func mangaByID(_ mangaID: UUID) -> FetchDescriptor<Manga> {
    var descriptor = FetchDescriptor<Manga>(predicate: #Predicate { $0.mangaID == mangaID })
    descriptor.fetchLimit = 1

    return descriptor
  }
}
