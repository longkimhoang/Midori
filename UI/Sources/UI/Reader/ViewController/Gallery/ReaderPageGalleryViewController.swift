//
//  ReaderPageGalleryViewController.swift
//  UI
//
//  Created by Long Kim on 24/12/24.
//

import Combine
import MidoriViewModels
import UIKit

final class ReaderPageGalleryViewController: UIViewController {
    var collectionView: UICollectionView! {
        view as? UICollectionView
    }

    var cancellables: Set<AnyCancellable> = []
    var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    let viewModel: ReaderViewModel

    @Published var selectedPageID: String?

    init(model: ReaderViewModel) {
        viewModel = model
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = String(localized: "All pages", bundle: .module)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [unowned self] _ in
                dismiss(animated: true)
            }
        )
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.delegate = self

        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()

        viewModel.$pages
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                let snapshot = dataSource.snapshot()
                updateDataSource(animated: !snapshot.itemIdentifiers.isEmpty)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Layout

private extension ReaderPageGalleryViewController {
    func makeCollectionViewLayout() -> UICollectionViewLayout {
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { _, layoutEnvironment in
            let estimatedItemWidth: CGFloat = 200
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let minItemCount: CGFloat = layoutEnvironment.traitCollection.horizontalSizeClass == .compact ? 2 : 3
            let itemCount = max(minItemCount, containerWidth / estimatedItemWidth)

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / itemCount),
                heightDimension: .uniformAcrossSiblings(estimate: 300)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(300)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            group.interItemSpacing = .flexible(16)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsetsReference = .layoutMargins
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

            return section
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

// MARK: - Data source

private extension ReaderPageGalleryViewController {}
