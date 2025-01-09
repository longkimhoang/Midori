//
//  UpdatesViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 8/1/25.
//

import UIKit

extension UpdatesViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [makeSectionHeader()]

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 16

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }

    func makeSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: itemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
    }
}
