//
//  MangaDetailController+DataSource.swift
//  UI
//
//  Created by Long Kim on 3/11/24.
//

import MidoriViewModels
import Nuke
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
                    group: chapter.groupName,
                    readableAt: chapter.readableAt
                )
            }
            cell.indentationWidth = 0
        }

        let mangaDetailHeaderRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
            [unowned self] headerView, _, manga in

            let imageRequest = ImageRequest(url: manga.coverImageURL)
            let image = ImagePipeline.midoriApp.cache.cachedImage(for: imageRequest).map { Image(uiImage: $0.image) }
            headerView.contentConfiguration = UIHostingConfiguration {
                MangaDetailHeaderView(
                    title: manga.title,
                    alternateTitle: manga.alternateTitle,
                    subtitle: manga.subtitle,
                    coverImage: image,
                    description: manga.synopsis,
                    rating: manga.rating
                )
                .environment(
                    \.expandMangaDescription,
                    .init { [unowned self] in
                        viewModel.mangaSynopsisExpanded()
                    }
                )
            }
            .margins(.all, 0)

            if image == nil {
                Task {
                    _ = try await ImagePipeline.midoriApp.image(for: imageRequest)
                    var snapshot = dataSource.snapshot()
                    snapshot.reconfigureItems([.mangaDetailHeader])
                    await dataSource.apply(snapshot)
                }
            }
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .mangaDetailHeader:
                return collectionView.dequeueConfiguredReusableCell(
                    using: mangaDetailHeaderRegistration,
                    for: indexPath,
                    item: viewModel.manga
                )
            case let .volume(volume):
                return collectionView.dequeueConfiguredReusableCell(
                    using: volumeCellRegistration,
                    for: indexPath,
                    item: volume.localizedDescription
                )
            case let .chapter(volume, id):
                let chapters = viewModel.chaptersByVolume[volume]
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
        snapshot.appendSections([.mangaDetailHeader])
        snapshot.appendItems([.mangaDetailHeader], toSection: .mangaDetailHeader)
        dataSource.apply(snapshot, animatingDifferences: animated)

        var hasExpandedSection = false
        for (volume, chapters) in viewModel.chaptersByVolume {
            let sectionIdentifier = SectionIdentifier.volume(volume)
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>()

            let volumeItemIdentifier = ItemIdentifier.volume(volume)
            sectionSnapshot.append([volumeItemIdentifier])

            let chapterItemIdentifiers = chapters.map(\.id).map { ItemIdentifier.chapter(volume, $0) }
            sectionSnapshot.append(chapterItemIdentifiers, to: volumeItemIdentifier)

            if !hasExpandedSection {
                sectionSnapshot.expand([volumeItemIdentifier])
                hasExpandedSection = true
            }

            dataSource.apply(sectionSnapshot, to: sectionIdentifier, animatingDifferences: animated)
        }
    }
}
