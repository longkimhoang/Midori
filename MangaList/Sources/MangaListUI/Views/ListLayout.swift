//
//  ListLayout.swift
//
//
//  Created by Long Kim on 15/3/24.
//

import SwiftUI

extension NSCollectionLayoutSection {
  static func mangaList(
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    #if os(iOS)
    let itemsPerRow = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 1 : 2
    #else
    let itemsPerRow = 2
    #endif
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 / CGFloat(itemsPerRow)),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(140)
    )
    #if os(iOS)
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: itemsPerRow
    )
    #else
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitem: item,
      count: itemsPerRow
    )
    group.interItemSpacing = .fixed(16)
    #endif
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

    return section
  }
}

#if os(iOS)
#else
extension NSCollectionViewLayout {
  static func mangaList() -> NSCollectionViewLayout {
    let configuration = NSCollectionViewCompositionalLayoutConfiguration()
    let layout = NSCollectionViewCompositionalLayout { _, layoutEnvironment in
      NSCollectionLayoutSection.mangaList(layoutEnvironment: layoutEnvironment)
    }
    layout.configuration = configuration

    return layout
  }
}
#endif
