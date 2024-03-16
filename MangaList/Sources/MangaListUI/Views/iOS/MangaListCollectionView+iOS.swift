//
//  MangaListCollectionView+iOS.swift
//
//
//  Created by Long Kim on 15/3/24.
//

#if os(iOS)
import Combine
import CommonUI
import ComposableArchitecture
import Database
import MangaListCore
import Nuke
import SwiftData
import SwiftUI

struct MangaListCollectionView: UIViewControllerRepresentable {
  let store: StoreOf<MangaListFeature>

  func makeUIViewController(context: Context) -> ViewController {
    let viewController = ViewController(initialLayout: store.layout)
    viewController.collectionView.delegate = context.coordinator
    viewController.collectionView.prefetchDataSource = context.coordinator
    context.coordinator.setupDataSource(for: viewController.collectionView)

    return viewController
  }

  func updateUIViewController(_: ViewController, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  @ViewAction(for: MangaListFeature.self)
  final class Coordinator: NSObject {
    let store: StoreOf<MangaListFeature>
    private lazy var imagePrefetcher = ImagePrefetcher()
    private lazy var cancellables: Set<AnyCancellable> = []
    private var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>!

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }

    func setupDataSource(for collectionView: UICollectionView) {
      let mangaListCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: { $0.thumbnailURL() }) {
          cell, _, manga, image in

          cell.contentConfiguration = UIHostingConfiguration {
            MangaListItemView(manga: manga, coverImage: image.map(Image.init))
          }
          .margins(.all, 0)
        } onLoadSuccess: { [weak self] indexPath, _ in
          self?.reconfigureItems(at: CollectionOfOne(indexPath))
        }

      let mangaGridCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewCell, Manga>(
          url: { $0.thumbnailURL(for: .medium) }
        ) { cell, _, manga, image in

          cell.contentConfiguration = UIHostingConfiguration {
            MangaGridItemView(manga: manga, coverImage: image.map(Image.init))
          }
          .margins(.all, 0)
        } onLoadSuccess: { [weak self] indexPath, _ in
          self?.reconfigureItems(at: CollectionOfOne(indexPath))
        }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = store.mangas[id: itemIdentifier] else { return nil }
          switch store.layout {
          case .list:
            return collectionView.dequeueConfiguredReusableCell(
              using: mangaListCellRegistration,
              for: indexPath,
              item: manga
            )
          case .grid:
            return collectionView.dequeueConfiguredReusableCell(
              using: mangaGridCellRegistration,
              for: indexPath,
              item: manga
            )
          }
        }

      observe { [weak self] in
        guard let self else { return }

        updateDataSource(with: store.mangas)
      }

      store.publisher.layout
        .dropFirst()
        .sink { [weak self] layout in
          guard let self else { return }
          updateLayout(of: collectionView, to: layout)
        }
        .store(in: &cancellables)
    }

    private func updateDataSource(with mangas: IdentifiedArrayOf<Manga>) {
      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>()
      snapshot.appendSections([.main])
      snapshot.appendItems(mangas.map(\.id))
      dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func reconfigureItems(at indexPaths: some Collection<IndexPath>) {
      let itemIdentifiers = indexPaths.compactMap(dataSource.itemIdentifier(for:))
      var snaphot = dataSource.snapshot()
      snaphot.reconfigureItems(itemIdentifiers)
      dataSource.apply(snaphot, animatingDifferences: false)
    }

    private func updateLayout(
      of collectionView: UICollectionView,
      to layout: MangaListFeature.State.Layout
    ) {
      collectionView.setCollectionViewLayout(
        ViewController.collectionViewLayout(for: layout),
        animated: false
      )
      var snapshot = dataSource.snapshot()
      snapshot.reloadSections([.main])
      dataSource.apply(snapshot, animatingDifferences: false)
    }
  }

  final class ViewController: UIViewController {
    private let initialLayout: MangaListFeature.State.Layout

    init(initialLayout: MangaListFeature.State.Layout) {
      self.initialLayout = initialLayout
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
      view = UICollectionView(
        frame: .zero,
        collectionViewLayout: Self.collectionViewLayout(for: initialLayout)
      )
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemGroupedBackground
      view.layoutMargins = .zero
    }

    var collectionView: UICollectionView {
      view as! UICollectionView
    }

    fileprivate static func collectionViewLayout(
      for layout: MangaListFeature.State.Layout
    ) -> UICollectionViewLayout {
      switch layout {
      case .list: .mangaList()
      case .grid: .mangaGrid()
      }
    }
  }
}

extension MangaListCollectionView.Coordinator: UICollectionViewDelegate {
  func collectionView(
    _: UICollectionView,
    willDisplay _: UICollectionViewCell,
    forItemAt indexPath: IndexPath
  ) {
    if indexPath.item == store.mangas.count - 1 {
      send(.delegate(.scrollEndReached))
    }
  }
}

extension MangaListCollectionView.Coordinator: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap {
      guard let itemIdentifier = dataSource.itemIdentifier(for: $0),
            let manga = store.mangas[id: itemIdentifier]
      else {
        return nil
      }

      return manga.thumbnailURL()
    }
  }

  func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    imagePrefetcher.startPrefetching(with: imageURLs(for: indexPaths))
  }

  func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    imagePrefetcher.stopPrefetching(with: imageURLs(for: indexPaths))
  }
}

private enum SectionIdentifier {
  case main
}
#endif
