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
      widthDimension: .absolute(128),
      heightDimension: .estimated(240)
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
    group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
      leading: .fixed(16),
      top: nil,
      trailing: nil,
      bottom: nil
    )
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
