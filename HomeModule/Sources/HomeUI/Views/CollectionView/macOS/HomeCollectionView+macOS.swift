//
//  HomeCollectionView+macOS.swift
//
//
//  Created by Long Kim on 11/3/24.
//

#if os(macOS)
import AdvancedCollectionTableView
import Combine
import CombineSchedulers
import ComposableArchitecture
import Database
import Dependencies
import FZUIKit
import HomeCore
import Nuke
import SnapKit
import SwiftData
import SwiftUI

struct HomeCollectionView: NSViewControllerRepresentable {
  let store: StoreOf<HomeFeature>

  func makeNSViewController(context _: Context) -> HomeCollectionViewController {
    HomeCollectionViewController(store: store)
  }

  func updateNSViewController(_: HomeCollectionViewController, context _: Context) {}

  @ViewAction(for: HomeFeature.self)
  final class HomeCollectionViewController: NSViewController {
    @ViewLoading
    private var collectionView: NSCollectionView
    @ViewLoading
    private var dataSource: NSCollectionViewDiffableDataSource<SectionIdentifier, PersistentIdentifier>
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
      let collectionView = NSCollectionView()
      collectionView.collectionViewLayout = .home()
      let scrollView = NSScrollView()
      scrollView.documentView = collectionView

      view = scrollView
      self.collectionView = collectionView
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      setupDataSource()
      collectionView.prefetchDataSource = self

      observe { [weak self] in
        guard let self else { return }
        switch store.fetchStatus {
        case let .success(data):
          updateDataSource(data: data)
        default:
          break
        }
      }
    }

    func setupDataSource() {
      func commonConfigure(indexPath: IndexPath, manga: Manga?, handler: (Image?) -> Void) {
        let imagePipeline = ImagePipeline.shared
        let request = ImageRequest(url: manga?.coverThumbnailURL)
        let image = imagePipeline.cache.cachedImage(for: request).map { Image(nsImage: $0.image) }

        handler(image)

        if image == nil {
          // Load image and reconfigure the cell
          imagePipeline.loadImage(with: request) { [weak self] result in
            switch result {
            case .success:
              self?.reconfigureItems(at: CollectionOfOne(indexPath))
            case .failure:
              break
            }
          }
        }
      }

      let popularMangaCellRegistration = NSCollectionView.ItemRegistration<
        NSCollectionViewItem,
        Manga
      > { item, indexPath, manga in
        commonConfigure(indexPath: indexPath, manga: manga) { image in
          item.contentConfiguration = NSHostingConfiguration {
            PopularMangaView(manga: manga, coverThumbnailImage: image)
          }
        }
      }

      let recentlyAddedCellRegistration = NSCollectionView.ItemRegistration<
        NSCollectionViewItem,
        Manga
      > { item, indexPath, manga in
        commonConfigure(indexPath: indexPath, manga: manga) { image in
          item.contentConfiguration = NSHostingConfiguration {
            RecentlyAddedMangaView(manga: manga, coverThumbnailImage: image)
          }
          .margins(.all, 0)
        }
      }

      let latestChapterCellRegistration = NSCollectionView.ItemRegistration<
        NSCollectionViewItem,
        Chapter
      > { item, indexPath, chapter in
        commonConfigure(indexPath: indexPath, manga: chapter.manga) { image in
          item.contentConfiguration = NSHostingConfiguration {
            LatestChapterView(chapter: chapter, coverThumbnailImage: image)
          }
          .margins(.all, 0)
        }
      }

      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier -> NSCollectionViewItem? in
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

            return collectionView.makeItem(
              using: popularMangaCellRegistration,
              for: indexPath,
              element: manga
            )
          case .latestUpdates:
            guard let chapter = data.latestChapters[id: itemIdentifier] else {
              return nil
            }

            return collectionView.makeItem(
              using: latestChapterCellRegistration,
              for: indexPath,
              element: chapter
            )
          case .recentlyAdded:
            guard let manga = data.recentlyAddedMangas[id: itemIdentifier] else {
              return nil
            }

            return collectionView.makeItem(
              using: recentlyAddedCellRegistration,
              for: indexPath,
              element: manga
            )
          }
        }

      let sectionTitleRegistration = NSCollectionView.SupplementaryRegistration<SectionTitleView>(
        elementKind: SupplementaryItemKind.sectionTitle
      ) { sectionTitleView, _, indexPath in
        guard let section = SectionIdentifier(rawValue: indexPath.section) else { return }

        sectionTitleView.contentConfiguration = NSHostingConfiguration {
          Group {
            switch section {
            case .popular:
              Text("Popular new titles", bundle: .module)
            case .latestUpdates:
              NavigationLink(state: HomeFeature.Path.State.latestUpdatesDetail(LatestUpdatesDetailFeature.State())) {
                Label("Latest updates", bundle: .module, systemImage: "chevron.forward")
                  .labelStyle(.sectionTitleNavigation)
              }
            case .recentlyAdded:
              Text("Recently added", bundle: .module)
            }
          }
          .font(.title)
          .foregroundStyle(.primary)
          .buttonStyle(.link)
        }
        .margins(.all, 0)
      }

      dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
        switch elementKind {
        case SupplementaryItemKind.sectionTitle:
          collectionView.makeSupplementaryView(
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
          reconfigureItems(at: collectionView.indexPathsForVisibleItems())
        }
        .store(in: &cancellables)
    }

    private func updateDataSource(data: HomeData) {
      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, PersistentIdentifier>()
      snapshot.appendSections([.popular, .latestUpdates, .recentlyAdded])
      snapshot.appendItems(data.popularMangas.map(\.id), toSection: .popular)
      snapshot.appendItems(data.latestChapters.map(\.id), toSection: .latestUpdates)
      snapshot.appendItems(data.recentlyAddedMangas.map(\.id), toSection: .recentlyAdded)
      dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func reconfigureItems(at indexPaths: some Collection<IndexPath>) {
      collectionView.reconfigureItems(at: Array(indexPaths))
    }
  }
}

extension HomeCollectionView.HomeCollectionViewController: NSCollectionViewPrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap { indexPath in
      guard let section = SectionIdentifier(rawValue: indexPath.section),
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

  func collectionView(_: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    prefetcher.startPrefetching(with: imageURLs(for: indexPaths))
  }

  func collectionView(_: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    prefetcher.stopPrefetching(with: imageURLs(for: indexPaths))
  }
}
#endif
