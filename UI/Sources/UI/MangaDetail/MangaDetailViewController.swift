//
//  MangaDetailViewController.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import ComposableArchitecture
import MidoriFeatures
import UIKit

final class MangaDetailViewController: UIViewController {
    typealias Chapter = MangaDetail.Chapter
    typealias Volume = MangaDetail.Volume

    enum SectionIdentifier: Int {
        case chapters
    }

    enum ItemIdentifier: Hashable {
        case volume(Volume)
        case chapter(Volume, UUID)
    }

    private var fetchMangaDetailTask: Task<Void, Never>?

    let store: StoreOf<MangaDetail>

    init(store: StoreOf<MangaDetail>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        fetchMangaDetailTask?.cancel()
    }

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>!

    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())

        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        store.send(.loadMangaFromStorage)
        observe { [unowned self] in
            updateDataSource()
        }

        fetchMangaDetailTask = Task {
            await store.send(.fetchMangaDetail).finish()
        }
    }
}
