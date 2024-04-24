//
//  HomeData.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import Foundation
import IdentifiedCollections
import Models

public struct HomeData: Equatable {
  public let popularMangas: IdentifiedArrayOf<Manga>
  public let recentlyAddedMangas: IdentifiedArrayOf<Manga>

  public struct FetchDescriptor: Sendable {
    public let popularMangaIDs: [UUID]
    public let recentlyAddedMangaIDs: [UUID]
  }
}
