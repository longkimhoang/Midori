//
//  HomeViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 28/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit

extension HomeViewController {
    typealias Manga = Home.Manga
    typealias Chapter = Home.Chapter

    func configureDataSource() {
        let popularMangaCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Int> {
            _, _, _ in
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, _ in

            return collectionView.dequeueConfiguredReusableCell(
                using: popularMangaCellRegistration,
                for: indexPath,
                item: 1
            )
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

    func updateDataSource(
        popularMangas _: IdentifiedArrayOf<Manga>,
        animated: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>()

        snapshot.appendSections([.popularMangas])
        snapshot.appendItems(store.popularMangas.ids.map(ItemIdentifier.popularManga))

        dataSource.apply(snapshot, animatingDifferences: animated)
    }
}
