//
//  NSCollectionLayoutBoundarySupplementaryItem+SectionTitle.swift
//
//
//  Created by Long Kim on 04/03/2024.
//

import Foundation
import SwiftUI

extension NSCollectionLayoutBoundarySupplementaryItem {
  static var sectionTitle: NSCollectionLayoutBoundarySupplementaryItem {
    let layoutSize = NSCollectionLayoutSize(
      widthDimension: .estimated(200),
      heightDimension: .estimated(44)
    )
    let item = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: layoutSize,
      elementKind: SupplementaryItemKind.sectionTitle,
      alignment: .topLeading
    )

    return item
  }
}
