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
import Database
import Dependencies
import Foundation
import HomeCore
import Nuke
import SwiftData
import SwiftUI

struct HomeCollectionView: UIViewControllerRepresentable {
  @Environment(\.refresh) private var refresh
  let fetchStatus: HomeDataFetchStatus
  @Binding var path: [HomeNavigationDestination]

  func makeUIViewController(context _: Context) -> ViewController {
    let viewController = ViewController()
    viewController.onRefresh = {
      await refresh?()
    }
    viewController.onNavigate = { destination in
      path.append(destination)
    }

    return viewController
  }

  func updateUIViewController(_ viewController: ViewController, context _: Context) {
    switch fetchStatus {
    case .loading:
      viewController.unavailableReason = .loading
    case let .success(homeData):
      viewController.unavailableReason = nil
      viewController.data = homeData
    case let .failure(error):
      viewController.unavailableReason = .error(error.localizedDescription)
    }

    viewController.setNeedsUpdateContentUnavailableConfiguration()
  }

  final class ViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<
      SectionIdentifier,
      PersistentIdentifier
    >!
    private lazy var prefetcher = ImagePrefetcher()
    private lazy var cancellables: Set<AnyCancellable> = []

    fileprivate var unavailableReason: HomeDataUnavailableReason?
    fileprivate var data: HomeData? {
      didSet {
        updateDataSource()
      }
    }

    fileprivate var onRefresh: () async -> Void = {}
    fileprivate var onNavigate: (HomeNavigationDestination) -> Void = { _ in }

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
      collectionView.refreshControl = UIRefreshControl(
        frame: .zero,
        primaryAction: UIAction { action in
          if let refreshControl = action.sender as? UIRefreshControl {
            Task { @MainActor [weak self] in
              guard let self else { return }
              await onRefresh()
              refreshControl.endRefreshing()
            }
          }
        }
      )

      setNeedsUpdateContentUnavailableConfiguration()
    }

    override var contentUnavailableConfigurationState: UIContentUnavailableConfigurationState {
      var state = super.contentUnavailableConfigurationState
      state[.homeDataUnavailableReason] = unavailableReason

      return state
    }

    override func updateContentUnavailableConfiguration(
      using state: UIContentUnavailableConfigurationState
    ) {
      switch state[.homeDataUnavailableReason] as? HomeDataUnavailableReason {
      case .loading:
        contentUnavailableConfiguration = UIContentUnavailableConfiguration.loading()
          .updated(for: state)
      case let .error(errorMessage):
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.text = String(localized: "Error fetching content", bundle: .module)
        configuration.secondaryText = errorMessage
        configuration.image = UIImage(
          systemName: "network.slash",
          compatibleWith: state.traitCollection
        )

        var retryButtonConfiguration = UIButton.Configuration.borderless()
        retryButtonConfiguration.title = String(localized: "Retry", bundle: .module)
        configuration.button = retryButtonConfiguration
        configuration.buttonProperties
          .primaryAction = UIAction(identifier: .refresh) { [weak self] _ in
            Task {
              await self?.onRefresh()
            }
          }

        contentUnavailableConfiguration = configuration
      case .none:
        contentUnavailableConfiguration = nil
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

          guard let data else {
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

      let sectionTitleRegistration = UICollectionView
        .SupplementaryRegistration<UICollectionViewCell>(
          elementKind: SupplementaryItemKind.sectionTitle
        ) { [weak self] sectionTitleView, _, indexPath in
          guard let section = SectionIdentifier(rawValue: indexPath.section) else { return }

          sectionTitleView.contentConfiguration = UIHostingConfiguration {
            Group {
              switch section {
              case .popular:
                Text("Popular new titles", bundle: .module)
              case .latestUpdates:
                Button {
                  self?.onNavigate(.latestUpdates)
                } label: {
                  Label("Latest updates", bundle: .module, systemImage: "chevron.forward")
                }
                .hoverEffect()
              case .recentlyAdded:
                Button {
                  self?.onNavigate(.recentlyAdded)
                } label: {
                  Label("Recently added", bundle: .module, systemImage: "chevron.forward")
                }
                .hoverEffect()
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

    func updateDataSource() {
      guard let data else { return }

      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, PersistentIdentifier>()
      snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
      snapshot.appendItems(data.popularMangas.ids.elements, toSection: .popular)
      snapshot.appendItems(data.latestChapters.ids.elements, toSection: .latestUpdates)
      snapshot.appendItems(data.recentlyAddedMangas.ids.elements, toSection: .recentlyAdded)
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

extension HomeCollectionView.ViewController: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap { indexPath in
      guard let section = dataSource.sectionIdentifier(for: indexPath.section),
            let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
      else {
        return nil
      }

      guard let data else {
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

fileprivate extension UIAction.Identifier {
  static var refresh = UIAction.Identifier("HomeCollectionView.refresh")
}

private enum HomeDataUnavailableReason: Hashable {
  case loading
  case error(String)
}

fileprivate extension UIConfigurationStateCustomKey {
  static let homeDataUnavailableReason =
    UIConfigurationStateCustomKey("HomeCollectionView.homeDataUnavailableReason")
}
#endif
