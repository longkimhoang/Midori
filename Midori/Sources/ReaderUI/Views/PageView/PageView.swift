//
//  PageView.swift
//
//
//  Created by Long Kim on 19/5/24.
//

import ComposableArchitecture
import ReaderCore
import SwiftUI

struct PageView: UIViewRepresentable {
  let store: StoreOf<ReaderFeature>

  func makeUIView(context _: Context) -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .singlePageLayout())

    return collectionView
  }

  func updateUIView(_: UICollectionView, context _: Context) {}
}
