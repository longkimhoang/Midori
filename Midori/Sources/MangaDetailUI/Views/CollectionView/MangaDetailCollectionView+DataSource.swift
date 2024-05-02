//
//  MangaDetailCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import MangaDetailCore
import SwiftUI
import UIKit

extension MangaDetailCollectionView.Coordinator {
  @MainActor
  func configureDataSource(collectionView: UICollectionView) {
    let volumeCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        cell, _, volume in

        var configuration = UIListContentConfiguration.plainHeader()
        configuration.text = volume
        cell.contentConfiguration = configuration

        let backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
        cell.backgroundConfiguration = backgroundConfiguration

        cell.accessories = [.outlineDisclosure(options: .init(style: .header))]
      }

    let chapterCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewListCell, MangaFeed.Chapter> {
        cell, _, chapter in

        cell.contentConfiguration = UIHostingConfiguration {
          Text(chapter.id.uuidString)
        }

        cell.indentationWidth = 0
        cell.accessories = [.disclosureIndicator()]
      }

    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
      elementKind: SupplementaryItemKind.mangaInfoHeader
    ) { [weak self] supplementaryView, _, _ in
      guard let self, let info = store.withState(\.fetchStatus.success?.info) else {
        return
      }

      supplementaryView.contentConfiguration = UIHostingConfiguration {
        MangaInfoView(info: info)
      }
      .margins(.vertical, 16)
    }

    dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
      [weak self] collectionView, indexPath, itemIdentifier in

      guard let self else { return nil }

      switch itemIdentifier {
      case let .volume(volume):
        let volume = if let volume {
          String(localized: "Volume \(volume)")
        } else {
          String(localized: "No volume")
        }

        return collectionView.dequeueConfiguredReusableCell(
          using: volumeCellRegistration,
          for: indexPath,
          item: volume
        )
      case let .chapter(chapterID):
        let chapter = store.withState { $0.fetchStatus.success?.chapters[id: chapterID] }
        return collectionView.dequeueConfiguredReusableCell(
          using: chapterCellRegistration,
          for: indexPath,
          item: chapter
        )
      }
    }

    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      if kind == SupplementaryItemKind.mangaInfoHeader {
        return collectionView.dequeueConfiguredReusableSupplementary(
          using: headerRegistration,
          for: indexPath
        )
      }

      return nil
    }
  }

  @MainActor
  func updateDataSource(with feed: MangaFeed) {
    let chapterIDsGroupedByVolume = feed.chapterIDsGroupedByVolume
    let volumes = chapterIDsGroupedByVolume.keys.elements.map { ItemIdentifier.volume($0) }

    var snapshot = SectionSnapshot()
    snapshot.append(volumes)

    for (volume, chapterIDs) in chapterIDsGroupedByVolume {
      let chapterIDs = chapterIDs.map { ItemIdentifier.chapter($0) }
      snapshot.append(chapterIDs, to: ItemIdentifier.volume(volume))
    }

    if let volume = volumes.first {
      snapshot.expand([volume])
    }

    dataSource.apply(snapshot, to: .chapters)
  }
}
