//
//  HomeData.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import CasePaths
import Database
import IdentifiedCollections

public struct HomeData {
  public let popularMangas: IdentifiedArrayOf<Manga>
  public let latestChapters: IdentifiedArrayOf<Chapter>
  public let recentlyAddedMangas: IdentifiedArrayOf<Manga>

  public init(
    popularMangas: IdentifiedArrayOf<Manga>,
    latestChapters: IdentifiedArrayOf<Chapter>,
    recentlyAddedMangas: IdentifiedArrayOf<Manga>
  ) {
    self.popularMangas = popularMangas
    self.latestChapters = latestChapters
    self.recentlyAddedMangas = recentlyAddedMangas
  }
}

@CasePathable
@dynamicMemberLookup
public enum HomeDataFetchStatus {
  case loading
  case success(HomeData)
  case failure(any Error)
}
