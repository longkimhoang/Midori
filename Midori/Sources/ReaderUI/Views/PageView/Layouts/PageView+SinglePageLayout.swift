//
//  PageView+SinglePageLayout.swift
//
//
//  Created by Long Kim on 19/5/24.
//

import UIKit

extension UICollectionViewLayout {
  static func singlePageLayout() -> UICollectionViewLayout {
    // Item
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 20
    section.orthogonalScrollingBehavior = .groupPaging

    return UICollectionViewCompositionalLayout(section: section)
  }
}
