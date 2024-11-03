//
//  MangaDetailController+DataSource.swift
//  UI
//
//  Created by Long Kim on 3/11/24.
//

import MidoriFeatures
import SwiftUI
import UIKit

extension MangaDetailViewController {
    func configureDataSource() {
        let volumeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> {
            cell, _, title in

            var contentConfiguration = UIListContentConfiguration.header()
            contentConfiguration.text = title
            contentConfiguration.axesPreservingSuperviewLayoutMargins = .horizontal
            contentConfiguration.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: 8,
                leading: 0,
                bottom: 8,
                trailing: 0
            )

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
        }

        let chapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Chapter> {
            cell, _, chapter in

            cell.contentConfiguration = UIHostingConfiguration {
                MangaDetailChapterView(
                    title: chapter.title,
                    group: chapter.group,
                    readableAt: chapter.readableAt
                )
            }
            cell.indentationWidth = 0
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .volume(volume):
                return collectionView.dequeueConfiguredReusableCell(
                    using: volumeCellRegistration,
                    for: indexPath,
                    item: volume.localizedDescription
                )
            case let .chapter(volume, id):
                let chapters = store.chaptersByVolume[volume]
                return collectionView.dequeueConfiguredReusableCell(
                    using: chapterCellRegistration,
                    for: indexPath,
                    item: chapters?[id: id]
                )
            }
        }
    }

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.chapters])
        dataSource.apply(snapshot, animatingDifferences: animated)

        var chaptersSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>()
        for (volume, chapters) in store.chaptersByVolume {
            let volumeItemIdentifier = ItemIdentifier.volume(volume)
            chaptersSectionSnapshot.append([volumeItemIdentifier])
            let chapterItemIdentifiers = chapters.map { ItemIdentifier.chapter(volume, $0.id) }
            chaptersSectionSnapshot.append(chapterItemIdentifiers, to: volumeItemIdentifier)
        }

        if let item = chaptersSectionSnapshot.items.first {
            chaptersSectionSnapshot.expand([item])
        }
        dataSource.apply(chaptersSectionSnapshot, to: .chapters, animatingDifferences: animated)
    }
}
