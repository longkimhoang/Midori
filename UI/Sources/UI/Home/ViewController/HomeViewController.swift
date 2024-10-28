//
//  HomeViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit

@ViewAction(for: Home.self)
final class HomeViewController: UIViewController {
    enum SectionIdentifier: Int {
        case popularMangas
    }

    enum ItemIdentifier: Hashable {
        case popularManga(UUID)
        case latestChapter(UUID)
        case recentlyAddedManga(UUID)
    }

    private var dataFetchingTask: Task<Void, Never>?

    let store: StoreOf<Home>

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>!

    init(store: StoreOf<Home>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = String(localized: "Home", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        dataFetchingTask?.cancel()
    }

    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        observe { [unowned self] in
            updateDataSource(popularMangas: store.popularMangas)
        }

        dataFetchingTask = Task {
            await send(.fetchHomeData).finish()
        }
    }
}
