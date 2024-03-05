//
//  NSCollectionLayoutSection+LatestUpdatesSection.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import Foundation
import SwiftUI

extension NSCollectionLayoutSection {
  static func latestUpdates(layoutEnvironment: NSCollectionLayoutEnvironment)
    -> NSCollectionLayoutSection
  {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .absolute(100)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    #if os(iOS)
    let itemsPerGroup = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 1 : 2
    #else
    let itemsPerGroup = 2
    #endif
    let baseRatio = 1 - 32 / (layoutEnvironment.container.effectiveContentSize.width)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(baseRatio / CGFloat(itemsPerGroup)),
      heightDimension: .estimated(300)
    )
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: 3
    )
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 32)
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
