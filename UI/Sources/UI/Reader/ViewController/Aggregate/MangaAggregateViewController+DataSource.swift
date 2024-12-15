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

            guard let volume = viewModel.aggregate.volumes[id: itemIdentifier.volume],
                  let chapter = volume.chapters[id: itemIdentifier.chapter]
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
            configuration.text = switch volume {
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
        var snapshot = NSDiffableDataSourceSnapshot<VolumeIdentifier, ItemIdentifier>()
        snapshot.appendSections(viewModel.aggregate.volumes.ids.elements)

        for volume in viewModel.aggregate.volumes {
            let itemIdentifiers = volume.chapters.ids.map { ItemIdentifier(volume: volume.id, chapter: $0) }
            snapshot.appendItems(itemIdentifiers, toSection: volume.id)
        }

        dataSource.apply(snapshot) { [weak self] in
            self?.highlightSelectedChapter()
        }
    }

    func highlightSelectedChapter() {
        guard let volume = viewModel.aggregate.volumes.first(
            where: { $0.chapters.ids.contains(viewModel.selectedChapter) }
        ) else {
            return
        }

        let itemIdentifier = ItemIdentifier(volume: volume.id, chapter: viewModel.selectedChapter)
        if let indexPath = dataSource.indexPath(for: itemIdentifier) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
}
