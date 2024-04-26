//
//  HomeCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Home
import SwiftUI

extension HomeCollectionView.Coordinator {
  func configureDataSource(collectionView: UICollectionView) {
    let popularMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.preservesSuperviewLayoutMargins = true
        cell.contentConfiguration = UIHostingConfiguration {
          PopularMangaView(manga: manga)
        }
        .margins(.all, 0)
      }

    let latestChaptersCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Chapter> {
        cell, _, chapter in

        cell.preservesSuperviewLayoutMargins = true
        cell.contentConfiguration = UIHostingConfiguration {
          Text(chapter.title ?? "Oneshot")
        }
        .background(.blue)
      }

    let recentlyAddedMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, _, manga in

        cell.preservesSuperviewLayoutMargins = true
        cell.contentConfiguration = UIHostingConfiguration {
          Text(manga.name.localized(for: .autoupdatingCurrent))
        }
        .background(.green)
      }

    dataSource = DataSource(collectionView: collectionView) {
      [weak self] collectionView, indexPath, itemIdentifier in

      guard let self, let data = store.withState(\.fetchStatus.success) else {
        return nil
      }

      switch itemIdentifier {
      case let .popular(id):
        guard let manga = data.popularMangas[id: id] else {
          return nil
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: popularMangaCellRegistration,
          for: indexPath,
          item: manga
        )
      case let .latestUpdates(id):
        guard let chapter = data.latestChapters[id: id] else {
          return nil
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: latestChaptersCellRegistration,
          for: indexPath,
          item: chapter
        )
      case let .recentlyAdded(id):
        guard let manga = data.recentlyAddedMangas[id: id] else {
          return nil
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: recentlyAddedMangaCellRegistration,
          for: indexPath,
          item: manga
        )
      }
    }

    // Supplementary views

    let sectionHeaderRegistration =
      UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
        elementKind: UICollectionView.elementKindSectionHeader
      ) { supplementaryView, _, indexPath in
        guard let sectionIdentifier = HomeCollectionView.SectionIdentifier(
          rawValue: indexPath.section
        ) else {
          return
        }

        let title = switch sectionIdentifier {
        case .popular: "Popular new titles"
        case .latestUpdates: "Latest updates"
        case .recentlyAdded: "Recently added"
        }

        supplementaryView.contentConfiguration = UIHostingConfiguration {
          HStack {
            Text(title)
            Spacer()
          }
          .font(.title)
          .multilineTextAlignment(.leading)
        }
        .margins(.horizontal, 0)
      }

    dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
      if elementKind == UICollectionView.elementKindSectionHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: sectionHeaderRegistration,
          for: indexPath
        )
      }

      return nil
    }
  }

  func updateDataSource(with data: HomeData, animated: Bool = true) {
    var snapshot = Snapshot()
    snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
    snapshot.appendItems(data.popularMangas.ids.map { .popular($0) }, toSection: .popular)
    snapshot.appendItems(
      data.latestChapters.ids.map { .latestUpdates($0) },
      toSection: .latestUpdates
    )
    snapshot.appendItems(
      data.recentlyAddedMangas.ids.map { .recentlyAdded($0) },
      toSection: .recentlyAdded
    )

    dataSource.apply(snapshot, animatingDifferences: animated)
  }
}
