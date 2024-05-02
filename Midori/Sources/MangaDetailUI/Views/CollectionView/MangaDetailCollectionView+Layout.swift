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

    let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
      _, layoutEnvironment in

      let section = NSCollectionLayoutSection.list(
        using: listConfiguration,
        layoutEnvironment: layoutEnvironment
      )
      section.boundarySupplementaryItems = [mangaInfoItem()]

      return section
    }

    let configuration = UICollectionViewCompositionalLayoutConfiguration()

    return UICollectionViewCompositionalLayout(
      sectionProvider: sectionProvider,
      configuration: configuration
    )
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
