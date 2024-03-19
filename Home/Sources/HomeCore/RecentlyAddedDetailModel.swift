//
//  RecentlyAddedDetailModel.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import Database
import Dependencies
import Foundation
import IdentifiedCollections

@MainActor
public final class RecentlyAddedDetailModel: ObservableObject {
  @Dependency(\.recentlyAddedMangas) private var recentlyAddedMangas
  private var isFetching: Bool = false
  private var offset: Int = 0

  @Published public var mangas: IdentifiedArrayOf<Manga> = []

  public init() {}

  public func fetchInitialMangas() {
    guard let mangas = try? IdentifiedArray(
      uniqueElements: recentlyAddedMangas.fetchInitialDetail()
    ) else {
      return
    }

    self.mangas = mangas
  }

  public func fetch() async {
    guard !isFetching else { return }

    isFetching = true
    defer { isFetching = false }

    do {
      let newMangas = try await recentlyAddedMangas.fetch(
        parameters: FetchRecentlyAddedMangasParameters(limit: 30, offset: offset)
      )

      if offset == 0 {
        // This is the initial fetch
        mangas = IdentifiedArray(uniqueElements: newMangas)
        offset = mangas.count
      } else {
        // Appends the result
        mangas.append(contentsOf: newMangas)
        offset += mangas.count
      }
    } catch {
      debugPrint(error)
    }
  }
}
