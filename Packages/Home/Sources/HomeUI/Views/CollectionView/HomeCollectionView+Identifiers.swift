//
//  HomeCollectionView+Identifiers.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Foundation
import UIKit

extension HomeCollectionView {
  enum SectionIdentifier: Int {
    case popular
    case latestUpdates
    case recentlyAdded
  }

  enum ItemIdentifier: Hashable {
    case popular(UUID)
    case latestUpdates(UUID)
    case recentlyAdded(UUID)
  }
}
