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
    layoutEnvironment: NSCollectionLayoutEnvironment
  ) -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    #if os(iOS)
    let ratio = 1.0
    #else
    let ratio = 1 - 32 / layoutEnvironment.container.effectiveContentSize.width
    #endif
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 * ratio),
      heightDimension: .estimated(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 32
    section.orthogonalScrollingBehavior = .groupPaging
    #if os(iOS)
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
    #else
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    #endif
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
