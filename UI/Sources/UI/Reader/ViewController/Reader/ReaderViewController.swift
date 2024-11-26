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

    @ViewLoading var navigationBar: UINavigationBar
    @ViewLoading var collectionView: UICollectionView
    @ViewLoading var pageViewController: UIPageViewController

    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, String>!

    let viewModel: ReaderViewModel
    let imagePrefetcher = ImagePrefetcher(pipeline: .midoriReader, maxConcurrentRequestCount: 5)

    init(model: ReaderViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
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
            try await viewModel.fetchPages()
        }
    }

    override var prefersStatusBarHidden: Bool {
        !viewModel.controlsVisible
    }

    @objc func handleTap(_ tap: UITapGestureRecognizer) {
        if tap.state == .ended {
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
