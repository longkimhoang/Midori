//
//  MangaListCollectionView.swift
//
//
//  Created by Long Kim on 29/4/24.
//

import ComposableArchitecture
import MangaList
import SwiftUI

struct MangaListCollectionView: UIViewControllerRepresentable {
  let store: StoreOf<MangaListFeature>

  func makeUIViewController(context: Context) -> ViewController {
    let initialLayout = store.withState(\.layout)
    return ViewController(initialLayout: initialLayout, coordinator: context.coordinator)
  }

  func updateUIViewController(_: ViewController, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  final class ViewController: UICollectionViewController {
    weak var coordinator: Coordinator!

    init(initialLayout: MangaListFeature.Layout, coordinator: Coordinator) {
      self.coordinator = coordinator

      super.init(collectionViewLayout: Self.layout(for: initialLayout))
      installsStandardGestureForInteractiveMovement = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      collectionView.preservesSuperviewLayoutMargins = true
    }
  }

  final class Coordinator: NSObject {
    let store: StoreOf<MangaListFeature>

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }
  }
}

// MARK: - Helpers

private extension MangaListCollectionView.ViewController {
  static func layout(for layout: MangaListFeature.Layout) -> UICollectionViewLayout {
    switch layout {
    case .grid: gridLayout
    case .list: listLayout
    }
  }
}
