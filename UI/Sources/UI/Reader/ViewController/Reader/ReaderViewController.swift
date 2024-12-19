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
import SwiftUI
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

    private lazy var toolbarHostingController: UIHostingController<ReaderToolbarView?> = {
        let controller = UIHostingController<ReaderToolbarView?>(rootView: nil)
        controller.sizingOptions = [.intrinsicContentSize]
        addChild(controller)
        controller.didMove(toParent: self)

        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .clear
        return controller
    }()

    @ViewLoading var collectionView: UICollectionView
    @ViewLoading var pageViewController: UIPageViewController

    var chapterFetchingTask: Task<Void, Error>?
    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, String>!

    var imageLoadingTask: Task<Void, Never>?
    @Published var imageLoadingEvents: [Page.ID: ImageTask.Event] = [:]

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

        let chapterListButton = UIBarButtonItem(
            title: String(localized: "Show chapters", bundle: .module),
            image: UIImage(systemName: "list.bullet"),
            target: self,
            action: #selector(chapterListButtonTapped)
        )

        let optionsButton = UIBarButtonItem(
            title: String(localized: "Show reader options", bundle: .module),
            image: UIImage(systemName: "gear"),
            target: self,
            action: #selector(optionsButtonTapped)
        )

        navigationItem.rightBarButtonItems = [optionsButton, chapterListButton]

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

        setupToolbar()
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
                UIView.animate(withDuration: UINavigationController.hideShowBarDuration) {
                    self.toolbarHostingController.view.alpha = visible ? 1 : 0
                }
            }
            .store(in: &cancellables)

        viewModel.$pages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                updateDataSource()
            }
            .store(in: &cancellables)

        viewModel.readerOptions.$useRightToLeftLayout
            .dropFirst()
            .sink { [unowned self] in
                updateReaderRightToLeftPreference(to: $0)
            }
            .store(in: &cancellables)

        viewModel.pageScrubber.$currentPage
            .dropFirst()
            .sink { [unowned self] page in
                navigateToPage(page - 1) // page is 1-indexed
            }
            .store(in: &cancellables)
    }

    override var prefersStatusBarHidden: Bool {
        !viewModel.controlsVisible
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

extension ReaderViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

// MARK: - Private

private extension ReaderViewController {
    func setupToolbar() {
        view.addSubview(toolbarHostingController.view)

        NSLayoutConstraint.activate([
            // toolbar
            toolbarHostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            toolbarHostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            toolbarHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        Publishers.CombineLatest(viewModel.$pages, viewModel.$displayingPageIDs)
            .filter { !$0.0.isEmpty && !$0.1.isEmpty }
            .map { pages, displayingPageIDs in
                let indices = displayingPageIDs
                    .compactMap { pages.index(id: $0) }
                    .map { String($0 + 1) }
                    .joined(separator: "-")

                return (indices, pages.count)
            }
            .sink { [unowned self] indices, pageCount in
                updateToolbarView(indices: indices, pageCount: pageCount)
            }
            .store(in: &cancellables)
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

    @objc func chapterListButtonTapped(_ sender: UIBarButtonItem) {
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
        navigationController.popoverPresentationController?.sourceItem = sender

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

    @objc func optionsButtonTapped(_ sender: UIBarButtonItem) {
        let optionsView = ReaderOptionsView(model: viewModel.readerOptions)
        let hostingController = UIHostingController(rootView: optionsView)
        hostingController.sizingOptions = [.preferredContentSize]
        hostingController.modalPresentationStyle = .popover
        hostingController.popoverPresentationController?.sourceItem = sender
        hostingController.popoverPresentationController?.backgroundColor = .clear
        hostingController.popoverPresentationController?.delegate = self
        hostingController.popoverPresentationController?.permittedArrowDirections = .up
        hostingController.view.backgroundColor = .clear

        present(hostingController, animated: true)
    }

    func updateReaderRightToLeftPreference(to isRTL: Bool) {
        let semanticContentAttribute: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .unspecified
        pageViewController.view.semanticContentAttribute = semanticContentAttribute

        let viewControllers = viewModel.displayingPageIDs.compactMap {
            viewModel.pages[id: $0].map(makeContentViewController)
        }

        guard !viewControllers.isEmpty else {
            return
        }

        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false)
    }

    func navigateToPage(_ pageIndex: Int) {
        guard viewModel.pages.indices.contains(pageIndex) else {
            return
        }

        let page = viewModel.pages[pageIndex]
        guard page.id != viewModel.displayingPageIDs.first else {
            return
        }

        let viewController = makeContentViewController(for: page)
        pageViewController.setViewControllers([viewController], direction: .forward, animated: false)
        viewModel.displayingPageIDs = [page.id]
    }

    func updateToolbarView(indices: String, pageCount: Int) {
        let toolbarView = ReaderToolbarView(
            indices: indices,
            pageCount: pageCount,
            pageScrubber: viewModel.pageScrubber,
            readerOptions: viewModel.readerOptions,
            onShowGalleryTapped: {}
        )
        toolbarHostingController.rootView = toolbarView
    }
}
