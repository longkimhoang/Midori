//
//  NSCollectionLayoutSection+PopularSection.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import SwiftUI

extension NSCollectionLayoutSection {
  static func popular(
    layoutEnvironment _: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
