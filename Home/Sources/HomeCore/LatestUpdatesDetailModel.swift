//
//  LatestUpdatesDetailModel.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import Database
import Dependencies
import Foundation
import IdentifiedCollections

@MainActor
public final class LatestUpdatesDetailModel: ObservableObject {
  @Dependency(\.latestChapters) var latestChapters

  @Published public var chapters: IdentifiedArrayOf<Chapter> = []

  public init() {}

  public func fetchInitialChapters() {
    guard let chapters = try? IdentifiedArray(uniqueElements: latestChapters.fetchInitialDetail())
    else {
      return
    }

    self.chapters = chapters
  }
}
