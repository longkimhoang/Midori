//
//  UpdatesViewController.swift
//  UI
//
//  Created by Long Kim on 2/1/25.
//

import Combine
import MidoriViewModels
import UIKit

final class UpdatesViewController: UIViewController {
    var collectionView: UICollectionView! {
        view as? UICollectionView
    }

    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<UUID, UUID>!

    let viewModel: UpdatesViewModel

    init(model: UpdatesViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = String(localized: "Updates", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        self.view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()

        try? viewModel.loadFollowedFeedFromStorage()
        updateDataSource(animated: false)

        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                updateDataSource()
            }
            .store(in: &cancellables)

        Task {
            try await viewModel.fetchFollowedFeed()
        }
    }
}
