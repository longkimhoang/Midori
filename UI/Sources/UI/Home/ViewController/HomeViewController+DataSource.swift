//
//  HomeViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import MidoriViewModels
import Nuke
import SwiftUI
import UIKit

extension HomeViewController {
    typealias HomeData = HomeViewModel.HomeData
    typealias Manga = HomeViewModel.Manga
    typealias Chapter = HomeViewModel.Chapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, (Manga, UIColor?)> {
            [unowned self] cell, indexPath, item in

            let (manga, dominantColor) = item

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)

            cell.contentConfiguration = PopularMangaConfiguration(
                title: manga.title,
                authors: manga.subtitle,
                coverImage: image
            )

            var backgroundConfiguration = UIBackgroundConfiguration.clear()
            backgroundConfiguration.cornerRadius = 16
            backgroundConfiguration.backgroundColor = dominantColor ?? .tertiarySystemFill

            cell.backgroundConfiguration = backgroundConfiguration

            cell.isAccessibilityElement = true

            let authorsFallback = String(localized: "authors unavailable", bundle: .module)
            cell.accessibilityLabel = "\(manga.title), \(manga.subtitle ?? authorsFallback)"

            switch (image, coverImageDominantColors[itemIdentifier]) {
            case (.none, _):
                fetchCoverImage(for: itemIdentifier)
            case let (.some(image), .none):
                Task {
                    coverImageDominantColors[itemIdentifier] = await computeDominantColor(for: image, context: context)
                    reconfigureItems(with: [itemIdentifier])
                }
            case (.some, .some):
                break
            }
        }

        let latestChapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Chapter> {
            [unowned self] cell, indexPath, chapter in

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)

            cell.contentConfiguration = UIHostingConfiguration {
                LatestChapterView(
                    manga: chapter.manga,
                    chapter: chapter.chapter,
                    group: chapter.group,
                    coverImage: image.map(Image.init)
                )
            }
            .margins(.all, 0)

            if image == nil {
                fetchCoverImage(for: itemIdentifier)
            }
        }

        let recentlyAddedMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
            [unowned self] cell, indexPath, manga in

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)
            cell.contentConfiguration = RecentlyAddedMangaConfiguration(
                title: manga.title,
                coverImage: image
            )

            if image == nil {
                fetchCoverImage(for: itemIdentifier)
            }
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            let cell: UICollectionViewCell?
            let dominantColor = coverImageDominantColors[itemIdentifier]

            switch itemIdentifier {
            case let .popularManga(id):
                let item = viewModel.data.popularMangas[id: id].map { ($0, dominantColor) }
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: popularMangaCellRegistration,
                    for: indexPath,
                    item: item
                )
            case let .latestChapter(id):
                let chapter = viewModel.data.latestChapters[id: id]
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: latestChapterCellRegistration,
                    for: indexPath,
                    item: chapter
                )
            case .recentlyAddedManga:
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: recentlyAddedMangaCellRegistration,
                    for: indexPath,
                    item: viewModel.data.recentlyAddedMangas[indexPath.item]
                )
            }

            return cell
        }

        let sectionHeaderLabelRegistration = UICollectionView.SupplementaryRegistration<HomeSectionHeaderLabelView>(
            elementKind: SupplementaryElementKind.sectionHeaderLabel
        ) { supplementaryView, _, _ in
            supplementaryView.text = String(localized: "Popular new titles")
        }

        let sectionHeaderButtonRegistration = UICollectionView.SupplementaryRegistration<HomeSectionHeaderButtonView>(
            elementKind: SupplementaryElementKind.sectionHeaderButton
        ) { [unowned self] button, _, indexPath in
            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
                return
            }

            switch sectionIdentifier {
            case .popularMangas:
                break
            case .latestChapters:
                button.label = String(localized: "Latest updates", bundle: .module)
                button.handler = { [unowned self] in
                    viewModel.latestUpdatesButtonTapped()
                }
            case .recentyAddedMangas:
                button.label = String(localized: "Recently added", bundle: .module)
                button.handler = { [unowned self] in
                    viewModel.recentlyAddedButtonTapped()
                }
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case SupplementaryElementKind.sectionHeaderLabel:
                collectionView.dequeueConfiguredReusableSupplementary(
                    using: sectionHeaderLabelRegistration,
                    for: indexPath
                )
            case SupplementaryElementKind.sectionHeaderButton:
                collectionView.dequeueConfiguredReusableSupplementary(
                    using: sectionHeaderButtonRegistration,
                    for: indexPath
                )
            default:
                nil
            }
        }
    }

    func updateDataSource(data: HomeData, animated: Bool = true) {
        guard !data.isEmpy else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()

        snapshot.appendSections([.popularMangas, .latestChapters, .recentyAddedMangas])
        snapshot.appendItems(data.popularMangas.ids.map(ItemIdentifier.popularManga), toSection: .popularMangas)
        snapshot.appendItems(data.latestChapters.ids.map(ItemIdentifier.latestChapter), toSection: .latestChapters)
        snapshot.appendItems(
            data.recentlyAddedMangas.ids.map(ItemIdentifier.recentlyAddedManga),
            toSection: .recentyAddedMangas
        )

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func reconfigureItems(with identifiers: [ItemIdentifier]) {
        var snapshot = dataSource.snapshot()
        snapshot.reconfigureItems(identifiers)
        dataSource.apply(snapshot)
    }
}
