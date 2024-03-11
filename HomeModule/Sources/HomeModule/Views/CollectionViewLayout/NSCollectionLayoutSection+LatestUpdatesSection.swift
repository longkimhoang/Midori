//
//  NSCollectionLayoutSection+LatestUpdatesSection.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import SwiftUI

extension NSCollectionLayoutSection {
  static func latestUpdates(layoutEnvironment: NSCollectionLayoutEnvironment)
    -> NSCollectionLayoutSection
  {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(100)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    #if os(iOS)
    let groupWidth = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 1 : 0.5
    #else
    let groupWidth = layoutEnvironment.container.effectiveContentSize.width > 1000 ? 1/3 : 0.5
    #endif
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(groupWidth),
      heightDimension: .estimated(300)
    )
    #if os(iOS)
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: 3
    )
    #else
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
    #endif
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
