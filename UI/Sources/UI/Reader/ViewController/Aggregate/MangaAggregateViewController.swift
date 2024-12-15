//
//  MangaAggregateViewController.swift
//  UI
//
//  Created by Long Kim on 14/12/24.
//

import Combine
import MidoriViewModels
import UIKit

final class MangaAggregateViewController: UIViewController {
    typealias VolumeIdentifier = ReaderViewModel.Aggregate.VolumeIdentifier
    typealias Chapter = ReaderViewModel.Aggregate.Chapter

    @ViewLoading var collectionView: UICollectionView

    var dataSource: UICollectionViewDiffableDataSource<VolumeIdentifier, UUID>!
    var cancellables: Set<AnyCancellable> = []

    let viewModel: MangaAggregateViewModel

    init(model: MangaAggregateViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = String(localized: "Chapters")
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
        collectionView.delegate = self

        view = collectionView
        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        configureDataSource()

        viewModel.$selectedChapter
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                highlightSelectedChapter()
            }
            .store(in: &cancellables)
    }
}
