//
//  MangaAggregateViewController.swift
//  UI
//
//  Created by Long Kim on 14/12/24.
//

import MidoriViewModels
import SwiftNavigation
import UIKit

final class MangaAggregateViewController: UIViewController {
    typealias VolumeIdentifier = ReaderViewModel.Aggregate.VolumeIdentifier
    typealias Chapter = ReaderViewModel.Aggregate.Chapter

    struct ItemIdentifier: Hashable {
        let volume: VolumeIdentifier
        let chapter: UUID
    }

    @ViewLoading var collectionView: UICollectionView

    var dataSource: UICollectionViewDiffableDataSource<VolumeIdentifier, ItemIdentifier>!
    let viewModel: MangaAggregateViewModel

    init(model: MangaAggregateViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.headerMode = .supplementary

        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        view = collectionView
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()

        observe { [unowned self] in
            let _ = viewModel.selectedChapter
            highlightSelectedChapter()
        }

        observe { [unowned self] in
            let _ = viewModel.aggregate
            configureDataSource()
        }
    }
}
