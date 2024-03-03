//
//  HomeData.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import Persistence

package struct HomeData {
  package let popular: [Manga]
  package let recentlyAdded: [Manga]

  package init(popular: [Manga], recentlyAdded: [Manga]) {
    self.popular = popular
    self.recentlyAdded = recentlyAdded
  }
}
