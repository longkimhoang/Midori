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
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalWidth(aspectRatio / itemsPerRow)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: Int(itemsPerRow)
    )
    group.interItemSpacing = .fixed(16)
    group.edgeSpacing = NSCollectionLayoutEdgeSpacing(
      leading: nil,
      top: .fixed(16),
      trailing: nil,
      bottom: .fixed(16)
    )

    let section = NSCollectionLayoutSection(group: group)
    #if os(iOS)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    section.contentInsetsReference = .layoutMargins
    #else
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    #endif

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
#endif
