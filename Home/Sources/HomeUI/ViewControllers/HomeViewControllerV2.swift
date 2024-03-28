//
//  HomeViewControllerV2.swift
//
//
//  Created by Long Kim on 28/3/24.
//

import ComposableArchitecture
import Database
import HomeCore
import SwiftData
import SwiftUI
import UIKit

@ViewAction(for: HomeFeature.self)
public final class HomeViewControllerV2: UIViewController {
  @ViewLoading @IBOutlet private var collectionView: UICollectionView
  @ViewLoading private var dataSource: UICollectionViewDiffableDataSource<
    SectionIdentifier,
    PersistentIdentifier
  >

  public let store: StoreOf<HomeFeature>

  public init?(coder: NSCoder, store: StoreOf<HomeFeature>) {
    self.store = store
    super.init(coder: coder)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    collectionView.collectionViewLayout = .home()
    #if !targetEnvironment(macCatalyst)
    collectionView.refreshControl = UIRefreshControl(
      frame: .zero,
      primaryAction: UIAction { [weak self] action in
        guard let self else { return }

        if let refreshControl = action.sender as? UIRefreshControl {
          Task {
            await self.send(.fetchData).finish()
            refreshControl.endRefreshing()
          }
        }
      }
    )
    #endif

    setupDataSource()

    send(.fetchData)
    observe { [weak self] in
      guard let self else { return }

      if let data = store.fetchStatus.success {
        updateDataSource(with: data)
      }

      setNeedsUpdateContentUnavailableConfiguration()

      if store.recentlyAddedDetail != nil {
        performSegue(withIdentifier: "ShowRecentlyAddedDetail", sender: self)
      }
    }
  }
}

// MARK: - Data Source

private extension HomeViewControllerV2 {
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
                self?.send(.navigateToRecentlyAddedDetail)
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

private extension HomeFeature.State {
  var dataUnavailableReason: HomeDataUnavailableReason? {
    switch fetchStatus {
    case .success: nil
    case .loading: .loading
    case let .failure(error): .error(error.localizedDescription)
    }
  }
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

public extension HomeViewControllerV2 {
  override var contentUnavailableConfigurationState: UIContentUnavailableConfigurationState {
    var state = super.contentUnavailableConfigurationState

    state.homeDataUnavailableReason = store.dataUnavailableReason
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
          await self?.send(.fetchData).finish()
        }
      }

      contentUnavailableConfiguration = configuration
    case .none:
      contentUnavailableConfiguration = nil
    }
  }
}

// MARK: - Presentations

extension HomeViewControllerV2 {
  @IBSegueAction func makeRecentlyAddedDetailViewController(_ coder: NSCoder) -> UIViewController? {
    guard let store = store.scope(
      state: \.recentlyAddedDetail,
      action: \.recentlyAddedDetail.presented
    ) else {
      return nil
    }

    return RecentlyAddedDetailViewControllerV2(coder: coder, store: store)
  }

  @IBAction func unwindToHomeViewController(_: UIStoryboardSegue) {
    store.send(.recentlyAddedDetail(.dismiss))
  }
}
