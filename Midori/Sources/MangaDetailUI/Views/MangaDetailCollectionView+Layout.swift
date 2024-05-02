//
//  MangaDetailCollectionView+Layout.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import UIKit

extension MangaDetailCollectionView.ViewController {
  static var layout: UICollectionViewLayout {
    var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
    listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden

    let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
    layout.configuration.boundarySupplementaryItems = [mangaInfoItem()]

    return layout
  }

  static func mangaInfoItem() -> NSCollectionLayoutBoundarySupplementaryItem {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(400)
    )

    let item = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: itemSize,
      elementKind: SupplementaryItemKind.mangaInfoHeader,
      alignment: .top
    )

    return item
  }
}
