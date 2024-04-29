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

  func makeUIViewController(context _: Context) -> ViewController {
    let initialLayout = store.withState(\.layout)
    return ViewController(initialLayout: initialLayout)
  }

  func updateUIViewController(_: ViewController, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(store: store)
  }

  final class ViewController: UICollectionViewController {
    weak var coordinator: Coordinator!

    init(initialLayout _: MangaListFeature.Layout) {
      super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }

  final class Coordinator: NSObject {
    let store: StoreOf<MangaListFeature>

    init(store: StoreOf<MangaListFeature>) {
      self.store = store
    }
  }
}
