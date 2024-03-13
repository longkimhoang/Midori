//
//  HomeCollectionView+iOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import Combine
import CombineSchedulers
import CommonUI
import ComposableArchitecture
import Database
import Foundation
import HomeCore
import Nuke
import SwiftData
import SwiftUI

struct HomeCollectionView: UIViewControllerRepresentable {
  let store: StoreOf<HomeFeature>

  func makeUIViewController(context _: Context) -> HomeCollectionViewController {
    HomeCollectionViewController(store: store)
  }

  func updateUIViewController(_: HomeCollectionViewController, context _: Context) {
    // Updates are handled through viewController's conneciton to store.
  }

  @ViewAction(for: HomeFeature.self)
  final class HomeCollectionViewController: UIViewController {
    @ViewLoading
    private var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, PersistentIdentifier>
    private lazy var prefetcher = ImagePrefetcher()
    private lazy var cancellables: Set<AnyCancellable> = []
    let store: StoreOf<HomeFeature>

    init(store: StoreOf<HomeFeature>) {
      self.store = store
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
      setupDataSource()
      collectionView.prefetchDataSource = self
      #if !targetEnvironment(macCatalyst)
      collectionView.refreshControl = UIRefreshControl(
        frame: .zero,
        primaryAction: UIAction { action in
          if let refreshControl = action.sender as? UIRefreshControl {
            Task { @MainActor [weak self] in
              guard let self else { return }
              await send(.fetchPopularMangas).finish()
              refreshControl.endRefreshing()
            }
          }
        }
      )
      #endif

      observe { [weak self] in
        guard let self else { return }
        switch store.fetchStatus {
        case let .success(data):
          updateDataSource(data: data)
        default:
          break
        }

        setNeedsUpdateContentUnavailableConfiguration()
      }
    }

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
      switch store.fetchStatus {
      case .success:
        contentUnavailableConfiguration = nil
      case .loading:
        contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading().updated(for: state)
      case let .failure(error):
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = String(localized: "Error fetching content", bundle: .module)
        configuration.secondaryText = error.localizedDescription
        configuration.image = UIImage(systemName: "network.slash", compatibleWith: state.traitCollection)

        var retryButtonConfiguration = UIButton.Configuration.borderless()
        retryButtonConfiguration.title = String(localized: "Retry", bundle: .module)
        configuration.button = retryButtonConfiguration
        configuration.buttonProperties.primaryAction = UIAction(identifier: .refresh) { [weak self] _ in
          self?.send(.fetchPopularMangas)
        }

        contentUnavailableConfiguration = configuration.updated(for: state)
      }
    }

    func setupDataSource() {
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
              self?.reconfigureCells(at: CollectionOfOne(indexPath))
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

          guard let data = store.fetchStatus.success else {
            return nil
          }

          switch section {
          case .popular:
            guard let manga = data.popularMangas[id: itemIdentifier] else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: popularMangaCellRegistration,
              for: indexPath,
              item: manga
            )
          case .latestUpdates:
            guard let chapter = data.latestChapters[id: itemIdentifier] else {
              return nil
            }

            return collectionView.dequeueConfiguredReusableCell(
              using: latestChapterCellRegistration,
              for: indexPath,
              item: chapter
            )
          case .recentlyAdded:
            guard let manga = data.recentlyAddedMangas[id: itemIdentifier] else {
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
              NavigationLink(
                state: HomeFeature.Path.State.latestUpdatesDetail(LatestUpdatesDetailFeature.State())
              ) {
                Label("Latest updates", bundle: .module, systemImage: "chevron.forward")
              }
            case .recentlyAdded:
              NavigationLink(
                state: HomeFeature.Path.State.recentlyAddedDetail(RecentlyAddedDetailFeature.State())
              ) {
                Label("Recently added", bundle: .module, systemImage: "chevron.forward")
              }
            }
          }
          .labelStyle(.sectionTitleNavigation)
          .font(.title)
          .foregroundStyle(.primary)
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

      @Dependency(\.mainQueue) var mainQueue
      Publishers.Timer(every: .seconds(60), scheduler: mainQueue)
        .autoconnect()
        .sink { [weak self] _ in
          guard let self else { return }
          reconfigureCells(at: collectionView.indexPathsForVisibleItems)
        }
        .store(in: &cancellables)
    }

    private func updateDataSource(data: HomeData) {
      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, PersistentIdentifier>()
      snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
      snapshot.appendItems(data.popularMangas.map(\.id), toSection: .popular)
      snapshot.appendItems(data.latestChapters.map(\.id), toSection: .latestUpdates)
      snapshot.appendItems(data.recentlyAddedMangas.map(\.id), toSection: .recentlyAdded)
      dataSource.apply(snapshot)
    }

    private func reconfigureCells(at indexPaths: some Collection<IndexPath>) {
      let itemIdentifiers = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
      var snapshot = dataSource.snapshot()
      snapshot.reconfigureItems(itemIdentifiers)
      dataSource.apply(snapshot, animatingDifferences: false)
    }
  }
}

extension HomeCollectionView.HomeCollectionViewController: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap { indexPath in
      guard let section = dataSource.sectionIdentifier(for: indexPath.section),
            let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
      else {
        return nil
      }

      guard let data = store.fetchStatus.success else {
        return nil
      }

      return switch section {
      case .popular:
        data.popularMangas[id: itemIdentifier]?.coverThumbnailURL
      case .latestUpdates:
        data.latestChapters[id: itemIdentifier]?.manga?.coverThumbnailURL
      case .recentlyAdded:
        data.recentlyAddedMangas[id: itemIdentifier]?.coverThumbnailURL
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

extension UIAction.Identifier {
  fileprivate static var refresh = UIAction.Identifier("HomeCollectionView.refresh")
}
#endif
