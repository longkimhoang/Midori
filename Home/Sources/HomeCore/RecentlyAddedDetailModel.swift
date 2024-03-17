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
  @Dependency(\.recentlyAddedMangas) var recentlyAddedMangas

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
}
