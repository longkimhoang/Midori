//
//  HomeCollectionView+iOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import CoreData
import Foundation
import HomeDomain
import Nuke
import Persistence
import SwiftUI

struct HomeCollectionView: UIViewControllerRepresentable {
  @Environment(\.refresh) var refresh
  let data: HomeData?

  func makeUIViewController(context: Context) -> HomeCollectionViewController {
    HomeCollectionViewController(coordinator: context.coordinator)
  }

  func updateUIViewController(_: HomeCollectionViewController, context: Context) {
    context.coordinator.homeData = data
    context.coordinator.refreshAction = refresh

    guard let data else { return }
    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, NSManagedObjectID>()
    snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
    snapshot.appendItems(data.popular.map(\.id), toSection: .popular)
    snapshot.appendItems(data.latestChapters.map(\.id), toSection: .latestUpdates)
    snapshot.appendItems(data.recentlyAdded.map(\.id), toSection: .recentlyAdded)
    context.coordinator.dataSource.apply(snapshot)
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(homeData: data)
  }

  final class Coordinator: NSObject {
    private lazy var prefetcher = ImagePrefetcher()
    var homeData: HomeData?
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, NSManagedObjectID>!
    var refreshAction: RefreshAction?

    init(homeData: HomeData?) {
      self.homeData = homeData
    }

    func setupDataSource(for collectionView: UICollectionView) {
      func commonConfigure(indexPath: IndexPath, manga: Manga?, handler: (Image?) -> Void) {
        let imagePipeline = ImagePipeline.shared
        let request = ImageRequest(url: manga?.coverThumbnailURL)
        let image = imagePipeline.cache.cachedImage(for: request).map { Image(uiImage: $0.image) }

        handler(image)

        if image == nil {
          // Load image and reconfigure the cell
          imagePipeline.loadImage(with: request) { [weak self] result in
            switch result {
            case .success:
              self?.reconfigureCell(at: indexPath)
            case .failure:
              break
            }
          }
        }
      }

      let popularMangaCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        Manga
      > { cell, indexPath, manga in
        commonConfigure(indexPath: indexPath, manga: manga) { image in
          cell.contentConfiguration = UIHostingConfiguration {
            PopularMangaView(manga: manga, coverThumbnailImage: image)
          }
          .margins(.all, 0)
        }
      }

      let recentlyAddedCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        Manga
      > { cell, indexPath, manga in
        commonConfigure(indexPath: indexPath, manga: manga) { image in
          cell.contentConfiguration = UIHostingConfiguration {
            RecentlyAddedMangaView(manga: manga, coverThumbnailImage: image)
          }
          .margins(.all, 0)
        }
      }

      let latestChapterCellRegistration = UICollectionView.CellRegistration<
        UICollectionViewCell,
        Chapter
      > { cell, indexPath, chapter in
        commonConfigure(indexPath: indexPath, manga: chapter.manga) { image in
          cell.contentConfiguration = UIHostingConfiguration {
            LatestChapterView(chapter: chapter, coverThumbnailImage: image)
          }
          .margins(.all, 0)
        }
      }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in
          guard let self,
                let section = SectionIdentifier(rawValue: indexPath.section)
          else {
            return nil
          }

          switch section {
          case .popular:
            guard let manga = manga(with: itemIdentifier, at: indexPath) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: manga
            )
          case .latestUpdates:
            guard let chapter = chapter(with: itemIdentifier, at: indexPath) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: latestChapterCellRegistration,
              for: indexPath,
              item: chapter
            )
          case .recentlyAdded:
            guard let manga = manga(with: itemIdentifier, at: indexPath) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: recentlyAddedCellRegistration,
              for: indexPath,
              item: manga
            )
          }
        }

      let sectionTitleRegistration = UICollectionView
        .SupplementaryRegistration<SectionTitleView>(
          elementKind: SupplementaryItemKind
            .sectionTitle
        ) { sectionTitleView, _, indexPath in
          guard let section = SectionIdentifier(rawValue: indexPath.section) else { return }
          let localizedTitle: String.LocalizationValue = switch section {
          case .popular:
            "Popular new titles"
          case .latestUpdates:
            "Latest updates"
          case .recentlyAdded:
            "Recently added"
          }

          sectionTitleView.configure(title: String(localized: localizedTitle))
        }

      dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
        switch elementKind {
        case SupplementaryItemKind.sectionTitle:
          collectionView.dequeueConfiguredReusableSupplementary(
            using: sectionTitleRegistration,
            for: indexPath
          )
        default:
          nil
        }
      }
    }

    private func manga(with identifier: NSManagedObjectID, at indexPath: IndexPath) -> Manga? {
      guard let homeData, let section = SectionIdentifier(rawValue: indexPath.section) else {
        return nil
      }

      return switch section {
      case .popular:
        homeData.popular[id: identifier]
      case .latestUpdates:
        nil
      case .recentlyAdded:
        homeData.recentlyAdded[id: identifier]
      }
    }

    private func chapter(with identifier: NSManagedObjectID, at indexPath: IndexPath) -> Chapter? {
      guard let homeData, let section = SectionIdentifier(rawValue: indexPath.section) else {
        return nil
      }

      return switch section {
      case .popular, .recentlyAdded:
        nil
      case .latestUpdates:
        homeData.latestChapters[id: identifier]
      }
    }

    private func reconfigureCell(at indexPath: IndexPath) {
      guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
        return
      }

      var snapshot = dataSource.snapshot()
      snapshot.reconfigureItems([itemIdentifier])
      dataSource.apply(snapshot, animatingDifferences: false)
    }
  }

  final class HomeCollectionViewController: UIViewController {
    let coordinator: Coordinator

    init(coordinator: Coordinator) {
      self.coordinator = coordinator
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
      view = UICollectionView(frame: .zero, collectionViewLayout: .home())
    }

    var collectionView: UICollectionView {
      view as! UICollectionView
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      view.layoutMargins = .zero
      coordinator.setupDataSource(for: collectionView)
      collectionView.prefetchDataSource = coordinator
      collectionView.refreshControl = UIRefreshControl(
        frame: .zero,
        primaryAction: UIAction { [weak self] action in
          if let refreshControl = action.sender as? UIRefreshControl {
            Task { @MainActor in
              await self?.coordinator.refreshAction?()
              refreshControl.endRefreshing()
            }
          }
        }
      )
    }
  }
}

extension HomeCollectionView.Coordinator: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    let identifiers = indexPaths.map { dataSource.itemIdentifier(for: $0) }
    return zip(identifiers, indexPaths).compactMap { identifier, indexPath -> URL? in
      guard let identifier else { return nil }
      return manga(with: identifier, at: indexPath)?.coverThumbnailURL
    }
  }

  func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    prefetcher.startPrefetching(with: imageURLs(for: indexPaths))
  }

  func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    prefetcher.stopPrefetching(with: imageURLs(for: indexPaths))
  }
}
#endif
