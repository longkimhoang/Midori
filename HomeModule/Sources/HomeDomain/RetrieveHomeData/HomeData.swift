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

  package let popular: Mangas
  package let recentlyAdded: Mangas

  package init(popular: Mangas, recentlyAdded: Mangas) {
    self.popular = popular
    self.recentlyAdded = recentlyAdded
  }
}
