//
//  HomeViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit
import SwiftUI

extension HomeViewController {
    typealias Manga = Home.Manga
    typealias Chapter = Home.Chapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
            cell, _, item in

            cell.contentConfiguration = UIHostingConfiguration {
                PopularMangaView(
                    title: item.title,
                    authors: item.subtitle
                )
            }
            .margins(.all, 16)
            .background {
                RoundedRectangle(cornerRadius: 16).fill(.gray.gradient)
            }
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            switch itemIdentifier {
            case .popularManga(let id):
                let manga = store.popularMangas[id: id]
                return collectionView.dequeueConfiguredReusableCell(
                    using: popularMangaCellRegistration,
                    for: indexPath,
                    item: manga
                )
            case .latestChapter:
                return nil
            case .recentlyAddedManga:
                return nil
            }
        }

        let sectionHeaderLabelRegistration = UICollectionView.SupplementaryRegistration<HomeSectionHeaderLabelView>(
            elementKind: SupplementaryElementKind.sectionHeaderLabel
        ) { supplementaryView, _, _ in
            supplementaryView.text = String(localized: "Popular new titles")
        }

        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case SupplementaryElementKind.sectionHeaderLabel:
                collectionView.dequeueConfiguredReusableSupplementary(
                    using: sectionHeaderLabelRegistration,
                    for: indexPath
                )
            default:
                nil
            }
        }
    }

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()

        snapshot.appendSections([.popularMangas])
        snapshot.appendItems(store.popularMangas.ids.map(ItemIdentifier.popularManga))

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
