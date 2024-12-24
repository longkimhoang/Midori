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
        static let separator = "separator"
    }

    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
            [unowned self] sectionIndex, layoutEnvironment in

            guard let section = dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }

            switch section {
            case .popularMangas:
                return makePopularMangasSection()
            case .latestChapters:
                return makeLatestChaptersSection(layoutEnvironment: layoutEnvironment)
            case .recentyAddedMangas:
                return makeRecentlyAddedMangasSection()
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .layoutMargins
        configuration.interSectionSpacing = 16

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }

    private func makePopularMangasSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(180))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 8
        section.boundarySupplementaryItems = [makeSectionHeaderLabel()]

        return section
    }

    private func makeLatestChaptersSection(
        layoutEnvironment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize,
            supplementaryItems: [makeSeparator(layoutEnvironment: layoutEnvironment)]
        )

        let contentWidth = layoutEnvironment.container.effectiveContentSize.width
        let estimatedItemWidth: CGFloat = 360
        let itemCount = max(1, (contentWidth / estimatedItemWidth).rounded(.towardZero))

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / itemCount),
            heightDimension: .estimated(180)
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 3
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 8
        section.boundarySupplementaryItems = [makeSectionHeaderButton()]

        return section
    }

    private func makeRecentlyAddedMangasSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .uniformAcrossSiblings(estimate: 140)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(128),
            heightDimension: .estimated(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.interGroupSpacing = 8
        section.boundarySupplementaryItems = [makeSectionHeaderButton()]

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

    private func makeSectionHeaderButton() -> NSCollectionLayoutBoundarySupplementaryItem {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: itemSize,
            elementKind: SupplementaryElementKind.sectionHeaderButton,
            alignment: .topLeading
        )
    }

    private func makeSeparator(
        layoutEnvironment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSupplementaryItem {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(1 / layoutEnvironment.traitCollection.displayScale)
        )
        return NSCollectionLayoutSupplementaryItem(
            layoutSize: itemSize,
            elementKind: SupplementaryElementKind.separator,
            containerAnchor: .init(edges: .bottom)
        )
    }
}
