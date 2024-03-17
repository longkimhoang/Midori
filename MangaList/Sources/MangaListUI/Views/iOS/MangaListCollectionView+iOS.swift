//
//  MangaListCollectionView+iOS.swift
//
//
//  Created by Long Kim on 15/3/24.
//

#if os(iOS)
import Combine
import CommonUI
import Database
import IdentifiedCollections
import Nuke
import SwiftData
import SwiftUI

struct MangaListCollectionView: UIViewControllerRepresentable {
  @Environment(\.mangaListEndReached) var mangaListEndReached
  let mangas: IdentifiedArrayOf<Manga>
  let layout: MangaListLayout

  func makeUIViewController(context: Context) -> ViewController {
    let viewController = ViewController(initialLayout: layout)
    viewController.collectionView.delegate = context.coordinator
    viewController.collectionView.prefetchDataSource = context.coordinator
    context.coordinator.setupDataSource(for: viewController.collectionView)

    return viewController
  }

  func updateUIViewController(_: ViewController, context: Context) {
    context.coordinator.mangas = mangas
    context.coordinator.layout = layout
    context.coordinator.onScrollEndReached = {
      Task {
        await mangaListEndReached()
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(layout: layout, mangas: mangas)
  }

  final class Coordinator: NSObject {
    fileprivate weak var collectionView: UICollectionView!
    private lazy var imagePrefetcher = ImagePrefetcher()
    private var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>!

    var layout: MangaListLayout {
      didSet {
        guard layout != oldValue else { return }
        updateLayout(of: collectionView, to: layout)
      }
    }

    var mangas: IdentifiedArrayOf<Manga> {
      didSet {
        updateDataSource()
      }
    }

    var onScrollEndReached: () -> Void = {}

    init(
      layout: MangaListLayout,
      mangas: IdentifiedArrayOf<Manga>
    ) {
      self.layout = layout
      self.mangas = mangas
    }

    func setupDataSource(for collectionView: UICollectionView) {
      self.collectionView = collectionView

      let mangaListCellRegistration =
        UICollectionView.CellRegistration<UICollectionViewCell, Manga>(url: { $0.thumbnailURL() }) {
          [weak self] cell, _, manga, image in

          guard let layout = self?.layout else { return }
          let image = image.map(Image.init)

          cell.contentConfiguration = UIHostingConfiguration {
            MangaItemView(manga: manga, image: image, layout: layout)
              .hoverEffect()
          }
          .margins(.all, 0)
        } onLoadSuccess: { [weak self] indexPath, _ in
          self?.reconfigureItems(at: CollectionOfOne(indexPath))
        }

      dataSource =
        UICollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = mangas[id: itemIdentifier] else { return nil }

          return collectionView.dequeueConfiguredReusableCell(
            using: mangaListCellRegistration,
            for: indexPath,
            item: manga
          )
        }
    }

    private func updateDataSource() {
      let itemIdentifiers = mangas.ids.elements
      guard dataSource.snapshot().itemIdentifiers != itemIdentifiers else { return }

      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>()
      snapshot.appendSections([.main])
      snapshot.appendItems(mangas.ids.elements)
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
      to layout: MangaListLayout
    ) {
      collectionView.setCollectionViewLayout(layout.collectionViewLayout, animated: true)
      var snapshot = dataSource.snapshot()
      snapshot.reconfigureItems(snapshot.itemIdentifiers)
      dataSource.apply(snapshot)
    }
  }

  final class ViewController: UIViewController {
    private let initialLayout: MangaListLayout

    init(initialLayout: MangaListLayout) {
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
        collectionViewLayout: initialLayout.collectionViewLayout
      )
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      additionalSafeAreaInsets = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
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
    if indexPath.item == mangas.count - 1 {
      onScrollEndReached()
    }
  }
}

extension MangaListCollectionView.Coordinator: UICollectionViewDataSourcePrefetching {
  private func imageURLs(for indexPaths: [IndexPath]) -> [URL] {
    indexPaths.compactMap {
      guard let itemIdentifier = dataSource.itemIdentifier(for: $0),
            let manga = mangas[id: itemIdentifier]
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

private extension MangaListLayout {
  var collectionViewLayout: UICollectionViewLayout {
    switch self {
    case .list: .mangaList()
    case .grid: .mangaGrid()
    }
  }
}
#endif
