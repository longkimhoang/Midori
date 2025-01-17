//
//  MangaDetailViewController.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import Combine
import Dependencies
import MidoriViewModels
import UIKit

final class MangaDetailViewController: UIViewController {
    typealias Manga = MangaDetailViewModel.Manga
    typealias Volume = MangaDetailViewModel.Volume

    enum SectionIdentifier: Hashable {
        case mangaDetailHeader
        case volume(Volume)
    }

    enum ItemIdentifier: Hashable {
        case mangaDetailHeader
        case volume(Volume)
        case chapter(Volume, UUID)
    }

    private var fetchMangaDetailTask: Task<Void, Error>?

    private(set) var cancellables: Set<AnyCancellable> = []
    let viewModel: MangaDetailViewModel

    init(model: MangaDetailViewModel) {
        viewModel = model
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
        collectionView.remembersLastFocusedIndexPath = true
        collectionView.delegate = self

        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        try? viewModel.loadMangaFromStorage()
        updateDataSource()

        let dataSourceChanges = Publishers.CombineLatest(
            viewModel.$manga.flatMap(\.publisher).removeDuplicates(),
            viewModel.$chaptersByVolume.removeDuplicates()
        )

        dataSourceChanges
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateDataSource()
            }
            .store(in: &cancellables)

        viewModel.navigationDestinationPublisher
            .sink { [unowned self] destination in
                switch destination {
                case .mangaSynopsis:
                    let viewController = MangaDetailDescriptionViewController()
                    viewController.navigationItem.title = viewModel.manga?.title
                    if let synopsis = viewModel.manga?.synopsis {
                        viewController.setContent(synopsis)
                    }

                    show(UINavigationController(rootViewController: viewController), sender: self)
                case let .chapter(id):
                    let model = withDependencies(from: viewModel) {
                        ReaderViewModel(chapterID: id)
                    }
                    let viewController = ReaderViewController(model: model)
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    present(navigationController, animated: true)
                }
            }
            .store(in: &cancellables)

        fetchMangaDetailTask = Task {
            try await viewModel.fetchMangaDetail()
        }
    }
}
