//
//  HomeViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import SwiftUI
import UIKit

extension HomeViewController {
    typealias Manga = Home.Manga
    typealias Chapter = Home.Chapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
            cell, _, manga in

            cell.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

            let configuration = PopularMangaConfiguration(
                title: manga.title,
                authors: manga.subtitle
            )
            cell.contentConfiguration = configuration

            var backgroundConfiguration = UIBackgroundConfiguration.clear()
            backgroundConfiguration.cornerRadius = 16
            backgroundConfiguration.backgroundColor = .tertiarySystemFill

            cell.backgroundConfiguration = backgroundConfiguration
        }

        let latestChapterCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Chapter> {
            _, _, _ in
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case let .popularManga(id):
                let manga = store.popularMangas[id: id]
                return collectionView.dequeueConfiguredReusableCell(
                    using: popularMangaCellRegistration,
                    for: indexPath,
                    item: manga
                )
            case let .latestChapter(id):
                let chapter = store.latestChapters[id: id]
                return collectionView.dequeueConfiguredReusableCell(
                    using: latestChapterCellRegistration,
                    for: indexPath,
                    item: chapter
                )
            case .recentlyAddedManga:
                return nil
            }
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
                button.label = String(localized: "Latest Updates", bundle: .module)
                button.handler = { [unowned self] in
                    store.send(.latestUpdatesButtonTapped)
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

        snapshot.appendSections([.popularMangas, .latestChapters])
        snapshot.appendItems(store.popularMangas.ids.map(ItemIdentifier.popularManga), toSection: .popularMangas)
        snapshot.appendItems(store.latestChapters.ids.map(ItemIdentifier.latestChapter), toSection: .latestChapters)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}

// MARK: - Cover image fetching

extension HomeViewController {}
