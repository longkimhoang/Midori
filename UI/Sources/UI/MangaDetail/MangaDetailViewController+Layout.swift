//
//  MangaDetailViewController+Layout.swift
//  UI
//
//  Created by Long Kim on 2/11/24.
//

import UIKit

extension MangaDetailViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = {
            [unowned self] sectionIndex, layoutEnvironment in

            guard let sectionIdentifier = dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }

            switch sectionIdentifier {
            case .mangaDetailHeader:
                return makeMangaDetailHeaderSection()
            case .volume:
                return makeVolumeSection(layoutEnvironment: layoutEnvironment)
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.contentInsetsReference = .layoutMargins

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }

    private func makeMangaDetailHeaderSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(400)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(400)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        return NSCollectionLayoutSection(group: group)
    }

    private func makeVolumeSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.headerMode = .firstItemInSection
        listConfiguration.headerTopPadding = 8

        let section = NSCollectionLayoutSection.list(using: listConfiguration, layoutEnvironment: layoutEnvironment)

        return section
    }
}
