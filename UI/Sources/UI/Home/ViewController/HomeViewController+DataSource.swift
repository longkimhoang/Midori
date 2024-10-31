//
//  HomeViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import Nuke
import SwiftUI
import UIKit

extension HomeViewController {
    typealias Manga = Home.Manga
    typealias Chapter = Home.Chapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, (Manga, UIColor?)> {
            [unowned self] cell, indexPath, item in

            let (manga, dominantColor) = item

            guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
                return
            }

            let image = cachedCoverImage(for: itemIdentifier)

            cell.configurationUpdateHandler = { cell, state in
                cell.contentConfiguration = UIHostingConfiguration {
                    PopularMangaView(
                        title: manga.title,
                        authors: manga.subtitle,
                        isHighlighted: state.isHighlighted,
                        coverImage: image.map(Image.init)
                    )
                }
                .margins(.all, 16)
                .background {
                    let color = dominantColor.map(Color.init)
                    let shapeStyle = color.map { AnyShapeStyle($0.gradient) } ?? AnyShapeStyle(.fill.tertiary)

                    RoundedRectangle(cornerRadius: 16)
                        .fill(shapeStyle)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.regularMaterial)
                        )
                }
            }

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

            cell.contentConfiguration = UIHostingConfiguration {
                RecentlyAddedMangaView(title: manga.title, coverImage: image.map(Image.init))
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
                let item = store.popularMangas[id: id].map { ($0, dominantColor) }
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: popularMangaCellRegistration,
                    for: indexPath,
                    item: item
                )
            case let .latestChapter(id):
                let chapter = store.latestChapters[id: id]
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: latestChapterCellRegistration,
                    for: indexPath,
                    item: chapter
                )
            case .recentlyAddedManga:
                cell = collectionView.dequeueConfiguredReusableCell(
                    using: recentlyAddedMangaCellRegistration,
                    for: indexPath,
                    item: store.recentlyAddedMangas[indexPath.item]
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
                    store.send(.latestUpdatesButtonTapped)
                }
            case .recentyAddedMangas:
                button.label = String(localized: "Recently added", bundle: .module)
                button.handler = { [unowned self] in
                    store.send(.recentlyAddedButtonTapped)
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

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()

        snapshot.appendSections([.popularMangas, .latestChapters, .recentyAddedMangas])
        snapshot.appendItems(store.popularMangas.ids.map(ItemIdentifier.popularManga), toSection: .popularMangas)
        snapshot.appendItems(store.latestChapters.ids.map(ItemIdentifier.latestChapter), toSection: .latestChapters)
        snapshot.appendItems(
            store.recentlyAddedMangas.ids.map(ItemIdentifier.recentlyAddedManga),
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
