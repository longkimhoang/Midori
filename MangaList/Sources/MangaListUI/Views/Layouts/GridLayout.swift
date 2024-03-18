//
//  GridLayout.swift
//
//
//  Created by Long Kim on 16/3/24.
//

import SwiftUI

extension NSCollectionLayoutSection {
  static func mangaGrid(
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    let estimatedItemWidth: CGFloat = 240
    let containerWidth = layoutEnvironment.container.effectiveContentSize.width
    let itemsPerRow = max((containerWidth / estimatedItemWidth).rounded(), 2)
    let aspectRatio = 1 / 0.7

    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 / itemsPerRow),
      heightDimension: .fractionalWidth(aspectRatio / itemsPerRow)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.edgeSpacing = NSCollectionLayoutEdgeSpacing(
      leading: nil,
      top: .flexible(0),
      trailing: nil,
      bottom: .flexible(0)
    )

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalWidth(aspectRatio / itemsPerRow)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )

    group.interItemSpacing = .fixed(16)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

    return NSCollectionLayoutSection(group: group)
  }
}

#if os(iOS)
extension UICollectionViewLayout {
  static func mangaGrid() -> UICollectionViewLayout {
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.contentInsetsReference = .layoutMargins

    let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
      NSCollectionLayoutSection.mangaGrid(layoutEnvironment: layoutEnvironment)
    }
    layout.configuration = configuration

    return layout
  }
}
#else
extension NSCollectionViewLayout {
  static func mangaGrid() -> NSCollectionViewLayout {
    let configuration = NSCollectionViewCompositionalLayoutConfiguration()

    let layout = NSCollectionViewCompositionalLayout { _, layoutEnvironment in
      NSCollectionLayoutSection.mangaGrid(layoutEnvironment: layoutEnvironment)
    }
    layout.configuration = configuration

    return layout
  }
}
#endif
