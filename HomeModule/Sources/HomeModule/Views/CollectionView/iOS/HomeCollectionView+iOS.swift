//
//  HomeCollectionView+iOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import Combine
import CombineSchedulers
import Database
import Dependencies
import Foundation
import Nuke
import SwiftData
import SwiftUI

struct HomeCollectionView: UIViewControllerRepresentable {
  @Environment(\.modelContext) var modelContext
  @Environment(\.refresh) var refresh
  @Bindable var model: HomeViewModel

  func makeUIViewController(context: Context) -> HomeCollectionViewController {
    HomeCollectionViewController(coordinator: context.coordinator)
  }

  func updateUIViewController(_ viewController: HomeCollectionViewController, context: Context) {
    context.coordinator.refreshAction = refresh
    context.coordinator.modelContext = modelContext

    switch model.fetchStatus {
    case let .success(data):
      context.coordinator.data = data
    case .loading:
      viewController.showLoading()
    case let .failure(error):
      viewController.showError(error) {
        model.fetchHomeData()
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(modelContext: modelContext)
  }

  @MainActor
  final class Coordinator: NSObject {
    private var timerCancellable: AnyCancellable?
    private lazy var prefetcher = ImagePrefetcher()
    var data: HomeData? {
      didSet {
        updateDataSource()
      }
    }

    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, PersistentIdentifier>!
    var refreshAction: RefreshAction?
    var modelContext: ModelContext
    @Dependency(\.mainQueue) var mainQueue

    init(modelContext: ModelContext) {
      self.modelContext = modelContext
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
          [weak self] collectionView, indexPath, itemIdentifier -> UICollectionViewCell? in
          guard let self,
                let section = SectionIdentifier(rawValue: indexPath.section)
          else {
            return nil
          }

          switch section {
          case .popular:
            guard let manga: Manga = modelContext.registeredModel(for: itemIdentifier) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: manga
            )
          case .latestUpdates:
            guard let chapter: Chapter = modelContext.registeredModel(for: itemIdentifier) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: latestChapterCellRegistration,
              for: indexPath,
              item: chapter
            )
          case .recentlyAdded:
            guard let manga: Manga = modelContext.registeredModel(for: itemIdentifier) else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: recentlyAddedCellRegistration,
              for: indexPath,
              item: manga
            )
          }
        }

      let sectionTitleRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
        elementKind: SupplementaryItemKind.sectionTitle
      ) { sectionTitleView, _, indexPath in
        guard let section = SectionIdentifier(rawValue: indexPath.section) else { return }

        sectionTitleView.contentConfiguration = UIHostingConfiguration {
          Group {
            switch section {
            case .popular:
              Text("Popular new titles", bundle: .module)
            case .latestUpdates:
              Text("Latest updates", bundle: .module)
            case .recentlyAdded:
              Text("Recently added", bundle: .module)
            }
          }
          .font(.title)
        }
        .margins(.vertical, 4)
        .margins(.horizontal, 0)
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

      timerCancellable = Publishers.Timer(every: .seconds(60), scheduler: mainQueue)
        .autoconnect()
        .sink { [weak self] _ in
          guard let self else { return }
          let visibleItemIdentifiers = collectionView.indexPathsForVisibleItems
            .compactMap { self.dataSource.itemIdentifier(for: $0) }
          var snapshot = dataSource.snapshot()
          snapshot.reconfigureItems(visibleItemIdentifiers)
          dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    private func updateDataSource() {
      if let data {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, PersistentIdentifier>()
        snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
        snapshot.appendItems(data.popularMangas.map(\.id), toSection: .popular)
        snapshot.appendItems(data.latestChapters.map(\.id), toSection: .latestUpdates)
        snapshot.appendItems(data.recentlyAddedMangas.map(\.id), toSection: .recentlyAdded)
        dataSource.apply(snapshot)
      } else {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot)
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

    func showLoading() {
      contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
    }

    func showError(_ error: Error, retryAction: @escaping () -> Void) {
      var configuration = UIContentUnavailableConfiguration.empty()
      configuration.text = String(localized: "Error fetching content", bundle: .module)
      configuration.secondaryText = error.localizedDescription

      var retryButtonConfiguration = UIButton.Configuration.borderless()
      retryButtonConfiguration.title = String(localized: "Retry", bundle: .module)
      configuration.button = retryButtonConfiguration
      configuration.buttonProperties.primaryAction = UIAction { _ in
        retryAction()
      }

      contentUnavailableConfiguration = configuration
    }
  }
}

extension HomeCollectionView.Coordinator: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    let identifiers = indexPaths.map { dataSource.itemIdentifier(for: $0) }
    return zip(identifiers, indexPaths).compactMap { identifier, _ -> URL? in
      guard let identifier else {
        return nil
      }

      switch modelContext.model(for: identifier) {
      case let manga as Manga:
        return manga.coverThumbnailURL
      case let chapter as Chapter:
        return chapter.manga?.coverThumbnailURL
      default:
        return nil
      }
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
