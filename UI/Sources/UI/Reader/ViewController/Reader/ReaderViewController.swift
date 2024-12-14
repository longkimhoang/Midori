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
import SwiftNavigation
import UIKit
import UIKitNavigation

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

    var chapterFetchingTask: Task<Void, Error>?
    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, String>!

    @UIBindable var viewModel: ReaderViewModel
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

        observe { [unowned self] in
            navigationBar.topItem?.title = viewModel.chapter?.title

            let navigationBarOpacity: Float = viewModel.controlsVisible ? 1 : 0
            if !navigationBar.layer.opacity.isApproximatelyEqual(to: navigationBarOpacity) {
                navigationBar.layer.opacity = navigationBarOpacity
                setNeedsStatusBarAppearanceUpdate()
            }
        }

        observe { [unowned self] in
            let _ = viewModel.pages
            updateDataSource()
        }
    }

    override var prefersStatusBarHidden: Bool {
        !viewModel.controlsVisible
    }

    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        guard tap.state == .ended else {
            return
        }

        let animation = UIKitAnimation.easeInOut(duration: 0.2)

        guard viewModel.controlsVisible else {
            withUIKitAnimation(animation) {
                viewModel.controlsVisible.toggle()
            }
            return
        }

        let location = tap.location(in: view)
        let navigationBarFrame = navigationBar.convert(navigationBar.bounds, to: view)

        if viewModel.controlsVisible, location.y > navigationBarFrame.maxY {
            withUIKitAnimation(animation) {
                viewModel.controlsVisible.toggle()
            }
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
