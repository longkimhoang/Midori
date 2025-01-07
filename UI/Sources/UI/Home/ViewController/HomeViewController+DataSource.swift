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
    typealias Chapter = HomeViewModel.LatestChapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, (Manga, UIColor?)> {
            [unowned self] cell, indexPath, item in

            let (manga, dominantColor) = item

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)

            cell.contentConfiguration = UIHostingConfiguration {
                PopularMangaView(
                    title: manga.title,
                    authors: manga.subtitle,
                    coverImage: image.map(Image.init)
                )
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: dominantColor ?? .tertiarySystemFill).gradient)
            }
            .margins(.all, 0)

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

        let latestChapterCellRegistration = UICollectionView.CellRegistration<LatestChapterCell, Chapter> {
            [unowned self] cell, indexPath, chapter in

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)

            var configuration = LatestChapterUIConfiguration()
            configuration.manga = chapter.mangaInfo.title
            configuration.chapter = chapter.chapter.title
            configuration.coverImage = image
            configuration.group = chapter.groupName

            cell.contentConfiguration = configuration

            if let contentView = cell.contentView as? LatestChapterUIView {
                NSLayoutConstraint.activate([
                    cell.separatorLayoutGuide.leadingAnchor.constraint(equalTo: contentView.mangaLabel.leadingAnchor),
                    cell.separatorLayoutGuide.trailingAnchor.constraint(equalTo: contentView.mangaLabel.trailingAnchor),
                ])
            }

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
            cell.contentConfiguration = UIHostingConfiguration {
                RecentlyAddedMangaView(
                    title: manga.title,
                    coverImage: image.map(Image.init)
                )
            }
            .margins(.all, 0)

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

        let sectionHeaderLabelRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
            elementKind: SupplementaryElementKind.sectionHeaderLabel
        ) { cell, _, _ in
            cell.contentConfiguration = UIHostingConfiguration {
                HomeSectionHeaderLabelView(content: String(localized: "Popular new titles", bundle: .module))
            }
            .margins(.horizontal, 0)
        }

        let sectionHeaderButtonRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
            elementKind: SupplementaryElementKind.sectionHeaderButton
        ) { [unowned self] cell, _, indexPath in
            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
                return
            }

            switch sectionIdentifier {
            case .popularMangas:
                break
            case .latestChapters:
                cell.contentConfiguration = UIHostingConfiguration {
                    HomeSectionHeaderButtonView(
                        label: String(localized: "Latest updates", bundle: .module)
                    ) { [unowned self] in
                        viewModel.latestUpdatesButtonTapped()
                    }
                }
                .margins(.horizontal, 0)
            case .recentyAddedMangas:
                cell.contentConfiguration = UIHostingConfiguration {
                    HomeSectionHeaderButtonView(
                        label: String(localized: "Recently added", bundle: .module)
                    ) { [unowned self] in
                        viewModel.latestUpdatesButtonTapped()
                    }
                }
                .margins(.horizontal, 0)
            }
        }

        let latestChapterSeparatorRegistration =
            UICollectionView.SupplementaryRegistration<LatestChapterCellSeparatorView>(
                elementKind: SupplementaryElementKind.separator
            ) { [unowned self] separator, _, indexPath in
                guard let cell = collectionView.cellForItem(at: indexPath) as? LatestChapterCell else {
                    return
                }

                separator.separatorView.frame = cell.separatorLayoutGuide.layoutFrame
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
            case SupplementaryElementKind.separator:
                collectionView.dequeueConfiguredReusableSupplementary(
                    using: latestChapterSeparatorRegistration,
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
