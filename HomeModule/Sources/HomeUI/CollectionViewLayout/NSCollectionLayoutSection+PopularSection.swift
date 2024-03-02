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
      heightDimension: .absolute(200)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    section.orthogonalScrollingBehavior = .groupPaging

    return section
  }
}
