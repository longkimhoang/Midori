//
//  HomeViewController.swift
//  UI
//
//  Created by Long Kim on 27/10/24.
//

import Combine
import CoreImage
import Dependencies
import MidoriViewModels
import Nuke
import UIKit

final class HomeViewController: UIViewController {
    enum SectionIdentifier {
        case popularMangas
        case latestChapters
        case recentyAddedMangas
    }

    enum ItemIdentifier: Hashable, Codable {
        case popularManga(UUID)
        case latestChapter(UUID)
        case recentlyAddedManga(UUID)
    }

    private lazy var cancellables: Set<AnyCancellable> = []
    private var dataFetchingTask: Task<Void, Error>?

    let viewModel: HomeViewModel
    let imagePrefetcher = ImagePrefetcher(pipeline: .midoriApp)
    nonisolated(unsafe) let context = CIContext()  // CIContext is thread-safe

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>!
    var coverImageDominantColors: [ItemIdentifier: UIColor] = [:]

    weak var transitionSourceView: UIView?

    init(model: HomeViewModel) {
        viewModel = model
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        #if !targetEnvironment(macCatalyst)
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif

        view = collectionView

        self.collectionView = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        try? viewModel.loadHomeDataFromStorage()
        updateDataSource(data: viewModel.data)

        viewModel.$data
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.updateDataSource(data: data)
            }
            .store(in: &cancellables)

        viewModel.navigationDestinationPublisher
            .sink { [unowned self] destination in
                switch destination {
                case let .mangaDetail(mangaID):
                    navigateToMangaDetail(mangaID: mangaID)
                case let .reader(chapterID):
                    let model = withDependencies(from: viewModel) {
                        ReaderViewModel(chapterID: chapterID)
                    }

                    let viewController = ReaderViewController(model: model)
                    let navigationController = UINavigationController(rootViewController: viewController)
                    navigationController.modalPresentationStyle = .fullScreen
                    present(navigationController, animated: true)
                }
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(viewModel.$isLoading, viewModel.$data.map(\.isEmpy))
            .map { isLoading, isEmpty -> UIContentConfiguration? in
                if isLoading, isEmpty {
                    return UIContentUnavailableConfiguration.loading()
                } else {
                    return nil
                }
            }
            .sink { [weak self] in
                self?.contentUnavailableConfiguration = $0
            }
            .store(in: &cancellables)

        dataFetchingTask = Task {
            try await viewModel.fetchHomeData()
        }
    }

    @objc private func refresh(_ sender: UIRefreshControl) {
        dataFetchingTask?.cancel()
        dataFetchingTask = Task {
            try await viewModel.fetchHomeData()
            sender.endRefreshing()
        }
    }
}

// MARK: - Navigation

extension HomeViewController {
    func navigateToMangaDetail(mangaID: UUID) {
        let model = withDependencies(from: viewModel) {
            MangaDetailViewModel(mangaID: mangaID)
        }

        let viewController = MangaDetailViewController(model: model)
        viewController.hidesBottomBarWhenPushed = true

        show(viewController, sender: self)
    }
}
