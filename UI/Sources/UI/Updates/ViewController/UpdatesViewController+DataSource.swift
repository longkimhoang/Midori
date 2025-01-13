//
//  UpdatesViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 9/1/25.
//

import MidoriViewModels
import Nuke
import SwiftUI
import UIKit

extension UpdatesViewController {
    func setupDataSource() {
        let chapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Chapter> {
            cell, _, chapter in

            cell.contentConfiguration = UIHostingConfiguration {
                MangaDetailChapterView(
                    title: chapter.title,
                    group: chapter.groupName,
                    readableAt: chapter.readableAt
                )
            }
        }

        let sectionHeaderRegistration =
            UICollectionView.CellRegistration<UICollectionViewListCell, UpdatesViewModel.Section.MangaInfo> {
                [unowned self] cell, _, mangaInfo in
                let imageRequest = ImageRequest(url: mangaInfo.coverImageURL, processors: [.resize(height: 120)])
                let image = ImagePipeline.midoriApp.cache.cachedImage(for: imageRequest).map {
                    Image(uiImage: $0.image)
                }

                cell.contentConfiguration = UIHostingConfiguration {
                    UpdatesSectionHeaderContentView(title: mangaInfo.title)
                }
                .background {
                    UpdatesSectionHeaderBackgroundView(coverImage: image)
                }

                if image == nil {
                    Task {
                        _ = try await ImagePipeline.midoriApp.image(for: imageRequest)
                        var snapshot = dataSource.snapshot()
                        snapshot.reconfigureItems([.header(mangaInfo.id)])
                        await dataSource.apply(snapshot)
                    }
                }
            }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .header(sectionIdentifier):
                let mangaInfo = viewModel.sections[id: sectionIdentifier]?.mangaInfo
                return collectionView.dequeueConfiguredReusableCell(
                    using: sectionHeaderRegistration,
                    for: indexPath,
                    item: mangaInfo
                )
            case let .item(itemIdentifier):
                let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section)
                let section = sectionIdentifier.flatMap { viewModel.sections[id: $0] }
                return collectionView.dequeueConfiguredReusableCell(
                    using: chapterCellRegistration,
                    for: indexPath,
                    item: section?.chapters[id: itemIdentifier]
                )
            }
        }
    }

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<UUID, ItemIdentifier>()
        for section in viewModel.sections {
            let sectionIdentifier = section.id
            snapshot.appendSections([sectionIdentifier])
            snapshot.appendItems([ItemIdentifier.header(sectionIdentifier)])
            snapshot.appendItems(section.chapters.map { ItemIdentifier.item($0.id) })
        }

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
