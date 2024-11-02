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

    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        store.send(.loadMangaFromStorage)

        fetchMangaDetailTask = Task {
            await store.send(.fetchMangaDetail).finish()
        }
    }
}
