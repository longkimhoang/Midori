//
//  MangaAggregateViewController.swift
//  UI
//
//  Created by Long Kim on 14/12/24.
//

import MidoriViewModels
import UIKit

final class MangaAggregateViewController: UIViewController {
    @ViewLoading private var collectionView: UICollectionView

    override func loadView() {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.headerMode = .supplementary

        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        view = collectionView
        self.collectionView = collectionView
    }
}
