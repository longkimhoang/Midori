//
//  ReaderViewController.swift
//  UI
//
//  Created by Long Kim on 13/11/24.
//

import Combine
import MidoriViewModels
import Nuke
import SnapKit
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

    @ViewLoading var navigationBar: UINavigationBar
    @ViewLoading var collectionView: UICollectionView
    @ViewLoading var pageViewController: UIPageViewController

    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, String>!

    let viewModel: ReaderViewModel
    let imagePrefetcher = ImagePrefetcher(pipeline: .midoriReader)

    init(model: ReaderViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
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

        view.addSubview(pageViewController.view)
        pageViewController.view.backgroundColor = .systemBackground
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addChild(pageViewController)
        pageViewController.didMove(toParent: self)

        let navigationBar = UINavigationBar()
        navigationBar.delegate = self

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview(\.safeAreaLayoutGuide)
        }

        self.view = view
        self.navigationBar = navigationBar
        self.pageViewController = pageViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let item = UINavigationItem()
        item.leftBarButtonItem = UIBarButtonItem(
            primaryAction: UIAction(
                title: String(localized: "Close", bundle: .module),
                image: UIImage(systemName: "xmark")
            ) { [unowned self] _ in
                dismiss(animated: true)
            }
        )

        navigationBar.setItems([item], animated: false)

        view.addGestureRecognizer(tapGesture)

        try? viewModel.loadChapterFromStorage()
        try? viewModel.loadPagesFromStorage()

        viewModel.$controlsVisible
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [unowned self] controlsVisible in
                UIView.animate(withDuration: 0.2) {
                    self.navigationBar.layer.opacity = controlsVisible ? 1 : 0
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
            .store(in: &cancellables)

        viewModel.$chapter.flatMap(\.publisher)
            .sink { [unowned self] chapter in
                navigationBar.topItem?.title = chapter.title
            }
            .store(in: &cancellables)

        viewModel.$pages
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                updateDataSource()
            }
            .store(in: &cancellables)

        Task {
            try await withThrowingDiscardingTaskGroup { group in
                group.addTask {
                    try await self.viewModel.fetchPages()
                }
                group.addTask {
                    try await self.viewModel.fetchAggregate()
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        !viewModel.controlsVisible
    }

    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else {
            return
        }

        guard viewModel.controlsVisible else {
            viewModel.controlsVisible.toggle()
            return
        }

        let location = tap.location(in: view)
        let navigationBarFrame = navigationBar.convert(navigationBar.bounds, to: view)

        if viewModel.controlsVisible, location.y > navigationBarFrame.maxY {
            viewModel.controlsVisible.toggle()
        }
    }
}

extension ReaderViewController: UIBarPositioningDelegate {
    func position(for bar: any UIBarPositioning) -> UIBarPosition {
        if bar === navigationBar {
            return .topAttached
        }

        return .any
    }
}

extension ReaderViewController: UINavigationBarDelegate {}

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
