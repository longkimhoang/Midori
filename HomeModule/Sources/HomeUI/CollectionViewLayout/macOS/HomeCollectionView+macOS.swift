//
//  HomeCollectionView+macOS.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

#if os(macOS)
import Foundation
import SwiftUI

struct HomeCollectionView: NSViewRepresentable {
  func makeNSView(context _: Context) -> NSCollectionView {
    let collectionView = NSCollectionView()
    collectionView.collectionViewLayout = .home()

    return collectionView
  }

  func updateNSView(_: NSCollectionView, context _: Context) {}
}
#endif
