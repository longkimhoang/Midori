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
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1 - 32/layoutEnvironment.container.contentSize.width),
      heightDimension: .estimated(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPaging
    section.interGroupSpacing = 32
    section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
    section.boundarySupplementaryItems = [.sectionTitle]

    return section
  }
}
