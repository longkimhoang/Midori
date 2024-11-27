//
//  ReaderViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 25/11/24.
//

import MidoriViewModels
import UIKit

extension ReaderViewController: UIPageViewControllerDataSource {
    typealias Page = ReaderViewModel.Page

    func updateDataSource(animated: Bool = true) {
        guard let page = viewModel.pages.first else {
            return
        }

        pageViewController.setViewControllers(
            [makeContentViewController(for: page)],
            direction: .forward,
            animated: animated
        )

        prefetchImages(for: viewModel.pages.elements)
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? ReaderPageContentViewController else {
            return nil
        }

        guard let index = viewModel.pages.index(id: viewController.page.id) else {
            return nil
        }

        let nextIndex = viewModel.pages.index(after: index)
        guard nextIndex < viewModel.pages.endIndex else {
            return nil
        }

        return makeContentViewController(for: viewModel.pages[nextIndex])
    }

    func pageViewController(
        _: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? ReaderPageContentViewController else {
            return nil
        }

        guard let index = viewModel.pages.index(id: viewController.page.id) else {
            return nil
        }

        guard index > viewModel.pages.startIndex else {
            return nil
        }

        let previousIndex = viewModel.pages.index(before: index)
        return makeContentViewController(for: viewModel.pages[previousIndex])
    }

    private func makeContentViewController(for page: Page) -> ReaderPageContentViewController {
        let viewController = ReaderPageContentViewController(page: page)
        viewController.isZoomedInPublisher
            .removeDuplicates()
            .sink { [unowned self] isZoomedIn in
                viewModel.controlsVisible = !isZoomedIn
            }
            .store(in: &cancellables)

        return viewController
    }
}
