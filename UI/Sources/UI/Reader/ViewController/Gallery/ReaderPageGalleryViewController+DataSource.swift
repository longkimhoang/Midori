//
//  ReaderPageGalleryViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 24/12/24.
//

import MidoriViewModels
import Nuke
import SwiftUI
import UIKit

extension ReaderPageGalleryViewController {
    typealias Page = ReaderViewModel.Page

    func setupDataSource() {
        let pageCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Page> {
            cell, indexPath, page in

            cell.configurationUpdateHandler = { cell, state in
                let isSelected = state.isSelected

                let request = ImageRequest(page: page, processors: [.resize(width: 200)])
                let image = ImagePipeline.midoriReader.cache.cachedImage(for: request).map { Image(uiImage: $0.image) }

                cell.contentConfiguration = UIHostingConfiguration {
                    ReaderGalleryPageView(pageNumber: indexPath.item + 1, isSelected: isSelected, image: image)
                }
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.fill.tertiary)
                    }
                }
                .margins(.all, 16)

                cell.isAccessibilityElement = true
                cell.accessibilityLabel = String(localized: "Page \(indexPath.item + 1)", bundle: .module)

                if image == nil {
                    Task { [weak self] in
                        _ = try? await ImagePipeline.midoriReader.image(for: request)

                        guard let self else {
                            return
                        }

                        var snapshot = dataSource.snapshot()
                        snapshot.reconfigureItems([page.id])
                        await dataSource.apply(snapshot)
                    }
                }
            }
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            [unowned self] collectionView, indexPath, itemIdentifier in

            let page = viewModel.pages[id: itemIdentifier]
            return collectionView.dequeueConfiguredReusableCell(
                using: pageCellRegistration,
                for: indexPath,
                item: page
            )
        }
    }

    func updateDataSource(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.pages.ids.elements)

        dataSource.apply(snapshot, animatingDifferences: animated) { [weak self] in
            guard let self else {
                return
            }

            selectedPageID = viewModel.displayingPageIDs.first

            let indexPath = selectedPageID.flatMap { dataSource.indexPath(for: $0) }
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
}
