//
//  HomeCollectionView+DataSource.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Common
import HomeCore
import Nuke
import SwiftUI

extension HomeCollectionView.Coordinator {
  @MainActor
  func configureDataSource(collectionView: UICollectionView) {
    let pipeline = ImagePipeline.default
    let popularMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        [weak self] cell, indexPath, manga in

        guard let self else { return }

        let request = ImageRequest(url: manga.coverImageURL)
        let image = pipeline.cache.cachedImage(for: request)?.image
        cell.contentConfiguration = UIHostingConfiguration {
          PopularMangaView(manga: manga, coverImage: image.map(Image.init))
        }
        .margins(.all, 0)

        if image == nil {
          Task {
            _ = try await pipeline.image(for: request)
            self.reconfigureItems(at: [indexPath])
          }
        }
      }

    let latestChaptersCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Chapter> {
        [weak self] cell, indexPath, chapter in

        guard let self else { return }

        let request = ImageRequest(url: chapter.coverImageURL)
        let image = pipeline.cache.cachedImage(for: request)?.image
        cell.contentConfiguration = UIHostingConfiguration {
          LatestChapterView(chapter: chapter, coverImage: image.map(Image.init))
        }
        .margins(.all, 0)

        if image == nil {
          Task {
            _ = try await pipeline.image(for: request)
            self.reconfigureItems(at: [indexPath])
          }
        }
      }

    let recentlyAddedMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga> {
        cell, indexPath, manga in

        let request = ImageRequest(url: manga.coverImageURL)
        let image = pipeline.cache.cachedImage(for: request)?.image
        cell.contentConfiguration = UIHostingConfiguration {
          RecentlyAddedMangaView(manga: manga, coverImage: image.map(Image.init))
        }
        .margins(.all, 0)

        if image == nil {
          Task {
            _ = try await pipeline.image(for: request)
            self.reconfigureItems(at: [indexPath])
          }
        }
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

        #if targetEnvironment(macCatalyst)
        let topMargins: CGFloat = sectionIdentifier == .popular ? 16 : 8
        #else
        let topMargins: CGFloat = 8
        #endif

        supplementaryView.contentConfiguration = UIHostingConfiguration { [weak self] in
          switch sectionIdentifier {
          case .popular:
            HStack {
              Text("Popular new titles", bundle: .module)
              Spacer()
            }
            .font(.title)
          case .latestUpdates:
            SectionTitleButton("Latest updates") {
              self?.store.send(.latestUpdatesButtonTapped)
            }
          case .recentlyAdded:
            SectionTitleButton("Recently added") {
              self?.store.send(.recentlyAddedButtonTapped)
            }
          }
        }
        .margins(.horizontal, 0)
        .margins(.top, topMargins)
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

  @MainActor
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

  @MainActor
  private func reconfigureItems(at indexPaths: [IndexPath]) {
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(indexPaths.compactMap(dataSource.itemIdentifier(for:)))

    dataSource.apply(snapshot, animatingDifferences: false)
  }
}
