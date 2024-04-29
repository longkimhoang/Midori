//
//  MangaListCollectionView+GridLayout.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import UIKit

extension MangaListCollectionView.ViewController {
  static var gridLayout: UICollectionViewLayout {
    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
      _, layoutEnvironment in

      section(layoutEnvironment: layoutEnvironment)
    }

    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }

  // MARK: - Sections

  private static func section(
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    // Item
    let itemCount = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 2 : 3
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 / CGFloat(itemCount)),
      heightDimension: .fractionalWidth(1 / (CGFloat(itemCount) * 0.7))
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Group
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(350)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: itemCount
    )
    group.interItemSpacing = .fixed(16)

    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsetsReference = .layoutMargins

    return section
  }
}
