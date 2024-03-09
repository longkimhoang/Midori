//
//  NSCollectionLayoutSection+RecentlyAddedSection.swift
//
//
//  Created by Long Kim on 05/03/2024.
//

import Foundation
import SwiftUI

extension NSCollectionLayoutSection {
  static func recentlyAdded(layoutEnvironment _: NSCollectionLayoutEnvironment)
    -> NSCollectionLayoutSection
  {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(128),
      heightDimension: .estimated(240)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
