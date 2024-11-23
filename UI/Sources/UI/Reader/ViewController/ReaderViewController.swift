//
//  ReaderViewController.swift
//  UI
//
//  Created by Long Kim on 13/11/24.
//

import Combine
import MidoriViewModels
import SnapKit
import UIKit

final class ReaderViewController: UIViewController {
    @ViewLoading var navigationBar: UINavigationBar

    var cancellables: Set<AnyCancellable> = []

    let viewModel: ReaderViewModel

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
        view.backgroundColor = .systemBackground

        let navigationBar = UINavigationBar()
        navigationBar.delegate = self

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview(\.safeAreaLayoutGuide)
        }

        self.view = view
        self.navigationBar = navigationBar
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

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

    override func contentScrollView(for edge: NSDirectionalRectEdge) -> UIScrollView? {
        super.contentScrollView(for: edge)
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
