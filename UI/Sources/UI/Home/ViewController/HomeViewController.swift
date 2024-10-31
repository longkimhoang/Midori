//
//  HomeViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture
import ConcurrencyExtras
import CoreImage
import MidoriFeatures
import Nuke
import UIKit

final class HomeViewController: UIViewController {
    enum SectionIdentifier {
        case popularMangas
        case latestChapters
        case recentyAddedMangas
    }

    enum ItemIdentifier: Hashable {
        case popularManga(UUID)
        case latestChapter(UUID)
        case recentlyAddedManga(UUID)
    }

    private var dataFetchingTask: Task<Void, Never>?

    let store: StoreOf<Home>
    let imagePrefetcher = ImagePrefetcher(pipeline: .midoriApp)
    nonisolated(unsafe) let context = CIContext() // CIContext is thread-safe

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>!
    var coverImageDominantColors: [ItemIdentifier: UIColor] = [:]

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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        collectionView.prefetchDataSource = self

        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        store.send(.loadHomeDataFromStorage)
        observe { [unowned self] in
            updateDataSource()
        }

        dataFetchingTask = Task {
            await store.send(.fetchHomeData).finish()
        }
    }
}
