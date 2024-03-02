//
//  HomeData.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APIClient
import Foundation

package struct HomeData {
  package let popular: [Manga]

  package init(popular: [Manga]) {
    self.popular = popular
  }
}
