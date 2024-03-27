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
import os.log

private let logger = Logger(subsystem: "com.longkimhoang.Midori", category: "DataFetching")

@MainActor
public final class RecentlyAddedDetailModel: ObservableObject {
  @Dependency(\.recentlyAddedMangas) private var recentlyAddedMangas
  private var offset: Int = 0

  @Published public var mangas: IdentifiedArrayOf<Manga> = []
  @Published public var isFetching: Bool = false

  public init() {}

  public func fetchInitialMangas() async {
    guard let mangas = try? IdentifiedArray(
      uniqueElements: recentlyAddedMangas.fetchInitialDetail()
    ) else {
      return
    }

    self.mangas = mangas
    try? await Task.sleep(for: .seconds(0.5))
    await refresh()
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
      logger.warning("Fetching new mangas failed with error: \(error)")
    }
  }

  public func refresh() async {
    isFetching = true
    defer { isFetching = false }

    var newMangas: IdentifiedArrayOf<Manga> = []
    do {
      while true {
        let result = try await recentlyAddedMangas.fetch(
          parameters: FetchRecentlyAddedMangasParameters(limit: 30, offset: offset)
        )

        let mangaIDs = Set(result.map(\.id))
        guard mangaIDs.union(mangas.ids).isEmpty else {
          break
        }

        newMangas.append(contentsOf: result)
      }
    } catch {
      logger.warning("Refreshing initial mangas failed with error: \(error)")
    }

    newMangas.append(contentsOf: mangas)
    mangas = newMangas
    offset = mangas.count
  }
}
