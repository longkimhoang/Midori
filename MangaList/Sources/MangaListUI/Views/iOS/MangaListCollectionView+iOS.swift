//
//  MangaListCollectionView+iOS.swift
//
//
//  Created by Long Kim on 15/3/24.
//

#if os(iOS)
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
    let viewController = ViewController()
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

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = store.mangas[id: itemIdentifier] else { return nil }
          return collectionView.dequeueConfiguredReusableCell(
            using: mangaListCellRegistration,
            for: indexPath,
            item: manga
          )
        }

      observe { [weak self] in
        guard let self else { return }

        updateDataSource(with: store.mangas)
      }
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
  }

  final class ViewController: UIViewController {
    override func loadView() {
      view = UICollectionView(frame: .zero, collectionViewLayout: .mangaList())
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .systemGroupedBackground
      view.layoutMargins = .zero
    }

    var collectionView: UICollectionView {
      view as! UICollectionView
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
