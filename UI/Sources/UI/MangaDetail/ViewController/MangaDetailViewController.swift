//
//  MangaDetailViewController.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import Combine
import ComposableArchitecture
import MidoriFeatures
import UIKit

final class MangaDetailViewController: UIViewController {
    typealias Manga = MangaDetail.Manga
    typealias Chapter = MangaDetail.Chapter
    typealias Volume = MangaDetail.Volume

    enum SectionIdentifier: Hashable {
        case mangaDetailHeader
        case volume(Volume)
    }

    enum ItemIdentifier: Hashable {
        case mangaDetailHeader
        case volume(Volume)
        case chapter(Volume, UUID)
    }

    private var fetchMangaDetailTask: Task<Void, Never>?

    var cancellables: Set<AnyCancellable> = []
    @UIBindable var store: StoreOf<MangaDetail>

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
        store.publisher
            .filter { $0.manga != nil }
            .removeDuplicates { $0.manga == $1.manga && $0.chaptersByVolume == $1.chaptersByVolume }
            .sink { [unowned self] state in
                updateDataSource(using: state)
            }
            .store(in: &cancellables)

        present(isPresented: $store.isDescriptionExpanded.sending(\.expandDescription)) { [unowned self] in
            let viewController = MangaDetailDescriptionViewController()
            viewController.navigationItem.title = store.manga?.title

            if let synopsis = store.manga?.synopsis {
                viewController.setContent(synopsis)
            }

            return UINavigationController(rootViewController: viewController)
        }

        fetchMangaDetailTask = Task {
            await store.send(.fetchMangaDetail).finish()
        }
    }
}
