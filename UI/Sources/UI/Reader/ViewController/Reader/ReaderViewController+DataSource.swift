//
//  ReaderViewController+DataSource.swift
//  UI
//
//  Created by Long Kim on 25/11/24.
//

import MidoriViewModels
import SwiftUI
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
            animated: false
        )

        viewModel.displayingPageIDs = [page.id]

        imagePrefetcher.stopPrefetching()
        imagePrefetcher.startPrefetching(with: viewModel.pages.map { .init(page: $0) })
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
            return makeNextChapterViewController()
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

    func makeContentViewController(for page: Page) -> ReaderPageContentViewController {
        ReaderPageContentViewController(page: page)
    }

    func makeNextChapterViewController() -> UIViewController? {
        guard let chapter = viewModel.chapter else {
            return nil
        }

        let nextChapterView = ReaderNextChapterView(
            manga: chapter.manga.title,
            currentChapter: chapter.title,
            nextChapter: viewModel.nextChapter?.chapter,
            coverImageURL: chapter.manga.coverImageURL,
            navigateToNextChapter: { [unowned self] in
                chapterFetchingTask?.cancel()
                chapterFetchingTask = Task {
                    guard let nextChapter = viewModel.nextChapter else {
                        return
                    }
                    await viewModel.switchChapter(to: nextChapter.id)
                }
            },
            closeReader: { [unowned self] in
                dismiss(animated: true)
            }
        )
        .ignoresSafeArea()

        let hostingController = UIHostingController(rootView: nextChapterView)
        hostingController.sizingOptions = [.intrinsicContentSize]

        return hostingController
    }
}
