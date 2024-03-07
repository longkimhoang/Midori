//
//  HomeData.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import IdentifiedCollections
import Persistence

package struct HomeData {
  package typealias Mangas = IdentifiedArrayOf<Manga>
  package typealias Chapters = IdentifiedArrayOf<Chapter>

  package let popular: Mangas
  package let latestChapters: Chapters
  package let recentlyAdded: Mangas

  package init(popular: Mangas, latestChapters: Chapters, recentlyAdded: Mangas) {
    self.popular = popular
    self.latestChapters = latestChapters
    self.recentlyAdded = recentlyAdded
  }
}
