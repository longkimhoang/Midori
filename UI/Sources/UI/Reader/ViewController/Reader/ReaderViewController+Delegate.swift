//
//  ReaderViewController+Delegate.swift
//  UI
//
//  Created by Long Kim on 16/12/24.
//

import UIKit

extension ReaderViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating _: Bool,
        previousViewControllers _: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else {
            return
        }

        let viewControllers = pageViewController.viewControllers ?? []
        viewModel.displayingPageIDs =
            viewControllers
            .compactMap { $0 as? ReaderPageContentViewController }
            .map(\.page.id)
    }
}
