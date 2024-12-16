//
//  ReaderViewController.swift
//  UI
//
//  Created by Long Kim on 13/11/24.
//

import Combine
import MidoriViewModels
import Nuke
import Numerics
import UIKit

final class ReaderViewController: UIViewController {
    enum SectionIdentifier {
        case main
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gesture.delegate = self
        return gesture
    }()

    @ViewLoading var collectionView: UICollectionView
    @ViewLoading var pageViewController: UIPageViewController

    var chapterFetchingTask: Task<Void, Error>?
    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, String>!

    let viewModel: ReaderViewModel
    let imagePrefetcher = ImagePrefetcher(pipeline: .midoriReader)

    init(model: ReaderViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            primaryAction: UIAction(
                title: String(localized: "Close", bundle: .module),
                image: UIImage(systemName: "xmark")
            ) { [unowned self] _ in
                dismiss(animated: true)
            }
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            primaryAction: UIAction(
                title: String(localized: "Show manga chapters list", bundle: .module),
                image: UIImage(systemName: "list.bullet")
            ) { [unowned self] _ in
                presentMangaAggregate()
            }
        )

        let navigationBarApperance = UINavigationBarAppearance()
        navigationBarApperance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = navigationBarApperance
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        chapterFetchingTask?.cancel()
        // When view is dismissed, clear the cache.
        ImagePipeline.midoriReader.cache.removeAll(caches: .memory)
    }

    override func loadView() {
        let view = UIView()

        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 20]
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self

        view.addSubview(pageViewController.view)
        pageViewController.view.backgroundColor = .systemBackground
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addChild(pageViewController)
        pageViewController.didMove(toParent: self)

        self.view = view
        self.pageViewController = pageViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(tapGesture)

        try? viewModel.loadChapterFromStorage()
        try? viewModel.loadPagesFromStorage()

        chapterFetchingTask = Task {
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await self.viewModel.fetchPages()
                }
                group.addTask {
                    try await self.viewModel.fetchAggregate()
                }
            }
        }

        viewModel.$chapter
            .compactMap { $0?.title }
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellables)

        viewModel.$controlsVisible
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] visible in
                navigationController?.setNavigationBarHidden(!visible, animated: true)
            }
            .store(in: &cancellables)

        viewModel.$pages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                updateDataSource()
            }
            .store(in: &cancellables)
    }

    override var prefersStatusBarHidden: Bool {
        !viewModel.controlsVisible
    }

    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else {
            return
        }

        guard viewModel.controlsVisible, let navigationBar = navigationController?.navigationBar else {
            viewModel.controlsVisible.toggle()
            return
        }

        let location = tap.location(in: view)
        let navigationBarFrame = navigationBar.convert(navigationBar.bounds, to: view)

        if viewModel.controlsVisible, location.y > navigationBarFrame.maxY {
            viewModel.controlsVisible.toggle()
        }
    }

    func presentMangaAggregate() {
        guard let aggregate = viewModel.aggregate else {
            return
        }

        let model = MangaAggregateViewModel(aggregate: aggregate, selectedChapter: viewModel.chapterID)
        let viewController = MangaAggregateViewController(model: model)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [unowned viewController] _ in
                viewController.dismiss(animated: true)
            }
        )

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem

        model.$selectedChapter
            .dropFirst()
            .sink { [unowned self] selectedChapter in
                chapterFetchingTask?.cancel()
                chapterFetchingTask = Task {
                    await viewModel.switchChapter(to: selectedChapter)
                }
                dismiss(animated: true)
            }
            .store(in: &cancellables)

        present(navigationController, animated: true)
    }
}

extension ReaderViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer === tapGesture else {
            return false
        }

        // check if other gesture is the double tap gesture of the content page
        let viewControllers = pageViewController.viewControllers ?? []
        for case let viewController as ReaderPageContentViewController in viewControllers {
            if viewController.doubleTapGestureRecognizer === otherGestureRecognizer {
                return true
            }
        }

        return false
    }
}
