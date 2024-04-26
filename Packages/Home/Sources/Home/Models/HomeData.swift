//
//  HomeData.swift
//
//
//  Created by Long Kim on 22/4/24.
//

import Foundation
import IdentifiedCollections
import Models

public struct HomeData: Equatable, Sendable {
  public let popularMangas: IdentifiedArrayOf<Manga>
  public let latestChapters: IdentifiedArrayOf<Chapter>
  public let recentlyAddedMangas: IdentifiedArrayOf<Manga>
}
