//
//  MangaDetailController+DataSource.swift
//  UI
//
//  Created by Long Kim on 3/11/24.
//

import MidoriFeatures
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
                    group: chapter.group,
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
                    description: "",
                    rating: manga.rating
                )
            }
            .margins(.all, 16)

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
                    item: store.manga
                )
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

    func updateDataSource(using state: MangaDetail.State, animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()
        snapshot.appendSections([.chapters])
        dataSource.apply(snapshot, animatingDifferences: animated)

        var chaptersSectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>()
        chaptersSectionSnapshot.append([.mangaDetailHeader])

        var hasExpandedSection = false
        for (volume, chapters) in state.chaptersByVolume {
            let volumeItemIdentifier = ItemIdentifier.volume(volume)
            chaptersSectionSnapshot.append([volumeItemIdentifier])
            let chapterItemIdentifiers = chapters.map { ItemIdentifier.chapter(volume, $0.id) }
            chaptersSectionSnapshot.append(chapterItemIdentifiers, to: volumeItemIdentifier)

            if !hasExpandedSection {
                chaptersSectionSnapshot.expand([volumeItemIdentifier])
                hasExpandedSection = true
            }
        }

        dataSource.apply(chaptersSectionSnapshot, to: .chapters, animatingDifferences: animated)
    }
}
