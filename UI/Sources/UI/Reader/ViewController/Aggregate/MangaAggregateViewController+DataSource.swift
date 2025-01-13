//
//  MangaAggregateViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 15/12/24.
//

import MidoriViewModels
import UIKit

extension MangaAggregateViewController {
    func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Chapter> {
            cell, _, chapter in

            var configuration = cell.defaultContentConfiguration()
            configuration.text = String(localized: "Chapter \(chapter.chapter)")

            cell.contentConfiguration = configuration
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            guard let volumeID = dataSource.sectionIdentifier(for: indexPath.section),
                  let volume = viewModel.aggregate.volumes[id: volumeID],
                  let chapter = volume.chapters[id: itemIdentifier]
            else {
                return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
                using: chapterCellRegistration,
                for: indexPath,
                item: chapter
            )
        }

        let volumeHeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [unowned self] cell, _, indexPath in
            guard let volume = dataSource.sectionIdentifier(for: indexPath.section) else {
                return
            }

            var configuration = UIListContentConfiguration.header()
            configuration.text =
                switch volume {
                case .none:
                    String(localized: "No volume")
                case let .volume(volume):
                    String(localized: "Volume \(volume)")
                }

            cell.contentConfiguration = configuration
        }

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: volumeHeaderRegistration,
                    for: indexPath
                )
            }

            return nil
        }
    }

    func configureDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<VolumeIdentifier, UUID>()
        snapshot.appendSections(viewModel.aggregate.volumes.ids.elements)

        for volume in viewModel.aggregate.volumes {
            snapshot.appendItems(volume.chapters.ids.elements, toSection: volume.id)
        }

        dataSource.apply(snapshot) { [weak self] in
            self?.highlightSelectedChapter()
        }
    }

    func highlightSelectedChapter() {
        guard let indexPath = dataSource.indexPath(for: viewModel.selectedChapter) else {
            return
        }

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
}
