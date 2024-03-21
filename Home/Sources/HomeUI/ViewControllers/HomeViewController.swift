//
//  HomeViewController.swift
//
//
//  Created by Long Kim on 18/3/24.
//

import Combine
import CommonUI
import Database
import HomeCore
import Nuke
import SwiftData
import SwiftUI
import UIKit

public final class HomeViewController: UIViewController {
  @ViewLoading private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    PersistentIdentifier
  >
  private lazy var model = HomeDataModel()
  private lazy var prefetcher = ImagePrefetcher()
  private lazy var cancellables: Set<AnyCancellable> = []

  private var dataUnavailableReason: HomeDataUnavailableReason? {
    didSet {
      if oldValue != dataUnavailableReason {
        setNeedsUpdateContentUnavailableConfiguration()
      }
    }
  }

  public init() {
    super.init(nibName: nil, bundle: nil)

    tabBarItem = UITabBarItem(
      title: String(localized: "Home"),
      image: UIImage(systemName: "house"),
      selectedImage: UIImage(systemName: "house.fill")
    )

    navigationItem.title = String(localized: "Home")

    #if targetEnvironment(macCatalyst)
    let refreshItem = UIBarButtonItem(
      systemItem: .refresh,
      primaryAction: UIAction { [weak self] _ in
        Task { @MainActor [weak self] in
          await self?.model.fetch()
        }
      }
    )
    navigationItem.rightBarButtonItem = refreshItem
    #endif
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func loadView() {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .home())
    collectionView.prefetchDataSource = self
    #if !targetEnvironment(macCatalyst)
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: UIAction { [weak self] action in
        if let refreshControl = action.sender as? UIRefreshControl {
          Task { @MainActor [weak self] in
            guard let self else { return }
            await model.fetch()
            refreshControl.endRefreshing()
          }
        }
      }
    )
    #endif

    view = collectionView
    self.collectionView = collectionView
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    collectionView.collectionViewLayout = .home()
    setupDataSource()
    setupSubscribers()

    Task {
      await model.fetch()
    }
  }
}

// MARK: - Subscribers

private extension HomeViewController {
  func setupSubscribers() {
    model.$fetchStatus
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fetchStatus in
        guard let self else { return }

        switch fetchStatus {
        case .loading:
          dataUnavailableReason = .loading
        case let .success(data):
          dataUnavailableReason = nil
          updateDataSource(with: data)
        case let .failure(error):
          dataUnavailableReason = .error(error.localizedDescription)
        }
      }
      .store(in: &cancellables)
  }
}

// MARK: - Data Source

private extension HomeViewController {
  func setupDataSource() {
    let getMangaCoverURL: (Manga) -> URL? = { $0.thumbnailURL() }
    let getChapterCoverURL: (Chapter) -> URL? = { $0.manga.flatMap(getMangaCoverURL) }

    let popularMangaCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: getMangaCoverURL) {
        cell, _, manga, image in

        cell.contentConfiguration = UIHostingConfiguration {
          PopularMangaView(manga: manga, coverThumbnailImage: image.map(Image.init))
        }
        .margins(.all, 0)
      } onLoadSuccess: { [weak self] indexPath, _ in
        self?.reconfigureCells(at: [indexPath])
      }

    let recentlyAddedCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: getMangaCoverURL) {
        cell, _, manga, image in

        cell.contentConfiguration = UIHostingConfiguration {
          RecentlyAddedMangaView(manga: manga, coverThumbnailImage: image.map(Image.init))
        }
        .margins(.all, 0)
      } onLoadSuccess: { [weak self] indexPath, _ in
        self?.reconfigureCells(at: [indexPath])
      }

    let latestChapterCellRegistration =
      UICollectionView.CellRegistration<UICollectionViewCell, Chapter>(url: getChapterCoverURL) {
        cell, _, chapter, image in

        cell.contentConfiguration = UIHostingConfiguration {
          LatestChapterView(chapter: chapter, coverThumbnailImage: image.map(Image.init))
        }
        .margins(.all, 0)
      } onLoadSuccess: { [weak self] indexPath, _ in
        self?.reconfigureCells(at: [indexPath])
      }

    dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
      [weak self] collectionView, indexPath, itemIdentifier in

      guard let self,
            let section = SectionIdentifier(rawValue: indexPath.section)
      else {
        return nil
      }

      guard let data = model.fetchStatus.success else {
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

    let sectionTitleRegistration =
      UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
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
//                self?.onNavigate(.latestUpdates)
              } label: {
                Label("Latest updates", bundle: .module, systemImage: "chevron.forward")
              }
              .hoverEffect()
            case .recentlyAdded:
              Button {
                self?.showRecentlyAddedDetail()
              } label: {
                Label("Recently added", bundle: .module, systemImage: "chevron.forward")
              }
              .hoverEffect()
            }
          }
          .labelStyle(.sectionTitleNavigation)
          .font(.title)
          .foregroundStyle(.primary)
          #if targetEnvironment(macCatalyst)
            .buttonStyle(.borderless)
          #endif
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
  }

  func updateDataSource(with data: HomeData) {
    var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, PersistentIdentifier>()
    snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
    snapshot.appendItems(data.popularMangas.ids.elements, toSection: .popular)
    snapshot.appendItems(data.latestChapters.ids.elements, toSection: .latestUpdates)
    snapshot.appendItems(data.recentlyAddedMangas.ids.elements, toSection: .recentlyAdded)
    dataSource.apply(snapshot)
  }

  private func reconfigureCells(at indexPaths: [IndexPath]) {
    let itemIdentifiers = indexPaths.compactMap { dataSource.itemIdentifier(for: $0) }
    var snapshot = dataSource.snapshot()
    snapshot.reconfigureItems(itemIdentifiers)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

// MARK: - Content Unavailable Configuration

private enum HomeDataUnavailableReason: Hashable {
  case loading
  case error(String)
}

private extension UIConfigurationStateCustomKey {
  static let homeDataUnavailableReason =
    UIConfigurationStateCustomKey("HomeViewController.dataUnavailableReason")
}

private extension UIContentUnavailableConfigurationState {
  var homeDataUnavailableReason: HomeDataUnavailableReason? {
    get { self[.homeDataUnavailableReason] as? HomeDataUnavailableReason }
    set { self[.homeDataUnavailableReason] = newValue }
  }
}

public extension HomeViewController {
  override var contentUnavailableConfigurationState: UIContentUnavailableConfigurationState {
    var state = super.contentUnavailableConfigurationState

    state.homeDataUnavailableReason = dataUnavailableReason
    return state
  }

  override func updateContentUnavailableConfiguration(
    using state: UIContentUnavailableConfigurationState
  ) {
    switch state.homeDataUnavailableReason {
    case .loading:
      contentUnavailableConfiguration =
        UIContentUnavailableConfiguration.loading().updated(for: state)
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
      configuration.buttonProperties.primaryAction = UIAction { [weak self] _ in
        Task {
          await self?.model.fetch()
        }
      }

      contentUnavailableConfiguration = configuration
    case .none:
      contentUnavailableConfiguration = nil
    }
  }
}

// MARK: - Presentations

extension HomeViewController {
  private func showRecentlyAddedDetail() {
    let viewController = RecentlyAddedDetailViewController()
    viewController.userActivity = userActivity
    navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Prefetching

extension HomeViewController: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap { indexPath in
      guard let section = dataSource.sectionIdentifier(for: indexPath.section),
            let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
      else {
        return nil
      }

      guard let data = model.fetchStatus.success else {
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

  public func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    prefetcher.startPrefetching(with: imageURLs(for: indexPaths))
  }

  public func collectionView(
    _: UICollectionView,
    cancelPrefetchingForItemsAt indexPaths: [IndexPath]
  ) {
    prefetcher.stopPrefetching(with: imageURLs(for: indexPaths))
  }
}

// MARK: - State restoration

public extension HomeViewController {
  override func updateUserActivityState(_: NSUserActivity) {
    navigationController?.topViewController
  }
}
