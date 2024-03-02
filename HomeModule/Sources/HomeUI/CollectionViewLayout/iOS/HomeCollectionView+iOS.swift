//
//  HomeCollectionView+iOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(iOS)
import Foundation
import SwiftUI

struct HomeCollectionView: UIViewRepresentable {
  func makeUIView(context _: Context) -> UICollectionView {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .home())

    return collectionView
  }

  func updateUIView(_: UICollectionView, context _: Context) {}
}
#endif
