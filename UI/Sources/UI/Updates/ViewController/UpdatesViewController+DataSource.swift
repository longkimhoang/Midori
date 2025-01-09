//
//  UpdatesViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 9/1/25.
//

import MidoriViewModels
import UIKit

extension UpdatesViewController {
    func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Chapter> {
            cell, indexPath, itemIdentifier in

        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section),
                let section = viewModel.sections[id: sectionIdentifier],
                let chapter = section.chapters[id: itemIdentifier]
            else {
                return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
                using: chapterCellRegistration,
                for: indexPath,
                item: chapter
            )
        }

        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [unowned self] supplementaryView, _, indexPath in
            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section),
                let section = viewModel.sections[id: sectionIdentifier]
            else {
                return
            }

            var contentConfiguration = supplementaryView.defaultContentConfiguration()
            contentConfiguration.text = section.mangaInfo.title

            supplementaryView.contentConfiguration = contentConfiguration
        }

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: sectionHeaderRegistration,
                    for: indexPath
                )
            }

            return nil
        }
    }

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<UUID, UUID>()
        for section in viewModel.sections {
            let sectionIdentifier = section.id
            snapshot.appendSections([sectionIdentifier])
            snapshot.appendItems(section.chapters.map(\.id))
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
