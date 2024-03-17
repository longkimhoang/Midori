//
//  MangaListCollectionView+macOS.swift
//
//
//  Created by Long Kim on 14/3/24.
//

#if os(macOS)
import AdvancedCollectionTableView
import Database
import FZUIKit
import IdentifiedCollections
import Nuke
import SnapKit
import SwiftData
import SwiftUI

struct MangaListCollectionView: NSViewRepresentable {
  @Environment(\.mangaListEndReached) var mangaListEndReached
  let mangas: IdentifiedArrayOf<Manga>
  let layout: MangaListLayout

  func makeNSView(context: Context) -> NSScrollView {
    let collectionView = NSCollectionView()
    collectionView.collectionViewLayout = .mangaList()
    collectionView.delegate = context.coordinator
    collectionView.prefetchDataSource = context.coordinator
    context.coordinator.setupDataSource(for: collectionView)

    let scrollView = NSScrollView()
    scrollView.documentView = collectionView
    return scrollView
  }

  func updateNSView(_: NSScrollView, context: Context) {
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
    private weak var collectionView: NSCollectionView!
    private lazy var imagePrefetcher = ImagePrefetcher()
    private var dataSource: NSCollectionViewDiffableDataSource<SectionIdentifier, Manga.ID>!

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

    func setupDataSource(for collectionView: NSCollectionView) {
      self.collectionView = collectionView

      let mangaListCellRegistration =
        NSCollectionView
          .ItemRegistration<MangaListItem, Manga>(url: { $0.thumbnailURL(for: .medium) }) {
            [weak self] item, _, manga, image in

            guard let layout = self?.layout else { return }
            item.configure(with: manga, coverImage: image, layout: layout)
          } onLoadSuccess: { [weak collectionView] indexPath, _ in
            collectionView?.reconfigureItems(at: [indexPath])
          }

      dataSource =
        NSCollectionViewDiffableDataSource(collectionView: collectionView) {
          [weak self] collectionView, indexPath, itemIdentifier in

          guard let self, let manga = mangas[id: itemIdentifier] else { return nil }
          return collectionView.makeItem(
            using: mangaListCellRegistration,
            for: indexPath,
            element: manga
          )
        }
    }

    private func updateDataSource() {
      let itemIdentifiers = mangas.ids.elements
      guard dataSource.snapshot().itemIdentifiers != itemIdentifiers else { return }

      var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, Manga.ID>()
      snapshot.appendSections([.main])
      snapshot.appendItems(mangas.map(\.id))
      dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateLayout(
      of collectionView: NSCollectionView,
      to layout: MangaListLayout
    ) {
      collectionView.animator().collectionViewLayout = layout.collectionViewLayout
      let indexPaths = collectionView.indexPaths(for: 0)
      collectionView.reconfigureItems(at: indexPaths)
    }
  }
}

extension MangaListCollectionView.Coordinator: NSCollectionViewDelegate {
  func collectionView(
    _: NSCollectionView,
    willDisplay _: NSCollectionViewItem,
    forRepresentedObjectAt indexPath: IndexPath
  ) {
    if indexPath.item == mangas.count - 1 {
      onScrollEndReached()
    }
  }
}

extension MangaListCollectionView.Coordinator: NSCollectionViewPrefetching {
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

  func collectionView(_: NSCollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    imagePrefetcher.startPrefetching(with: imageURLs(for: indexPaths))
  }

  func collectionView(_: NSCollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    imagePrefetcher.stopPrefetching(with: imageURLs(for: indexPaths))
  }
}

private enum SectionIdentifier {
  case main
}

private final class MangaListItem: NSCollectionViewItem {
  private var hostingView: NSHostingView<MangaItemView>!

  func configure(with manga: Manga, coverImage: NSImage?, layout: MangaListLayout) {
    let image = coverImage.map(Image.init(nsImage:))
    let rootView = MangaItemView(manga: manga, image: image, layout: layout)

    if let hostingView {
      hostingView.rootView = rootView
    } else {
      hostingView = NSHostingView(rootView: rootView)
      view.addSubview(hostingView)
      hostingView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
      }
    }
  }
}

private extension MangaListLayout {
  var collectionViewLayout: NSCollectionViewLayout {
    switch self {
    case .list: .mangaList()
    case .grid: .mangaGrid()
    }
  }
}
#endif
