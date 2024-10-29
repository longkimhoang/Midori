//
//  HomeViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import UIKit

extension HomeViewController {
    enum SupplementaryElementKind {
        static let sectionHeaderLabel = "section-header-label"
        static let sectionHeaderButton = "section-header-button"
    }

    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [unowned self] sectionIndex, _ in
            guard let section = dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }

            switch section {
            case .popularMangas:
                return makePopularMangasSection()
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .layoutMargins

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }

    private func makePopularMangasSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 32
        section.boundarySupplementaryItems = [makeSectionHeaderLabel()]

        return section
    }

    private func makeSectionHeaderLabel() -> NSCollectionLayoutBoundarySupplementaryItem {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: itemSize,
            elementKind: SupplementaryElementKind.sectionHeaderLabel,
            alignment: .topLeading
        )
    }
}
