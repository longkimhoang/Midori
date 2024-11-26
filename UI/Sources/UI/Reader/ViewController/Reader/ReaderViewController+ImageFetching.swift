//
//  ReaderViewController+ImageFetching.swift
//  UI
//
//  Created by Long Kim on 15/11/24.
//

import MidoriViewModels
import Nuke

extension ImageRequest {
    init(page: ReaderViewModel.Page, processors: [ImageProcessing] = []) {
        self.init(url: page.imageURL, processors: processors, userInfo: [.imageIdKey: page.id])
    }
}

extension ReaderViewController {
    func prefetchImages(for pages: [ReaderViewModel.Page]) {
        // pages are only refetched on a new chapter or when the current page image URLs
        // has become invalid (perhaps because the MangaDex@Home server has changed)
        // therefore, we can safely cancel all pending prefetches and start anew
        imagePrefetcher.stopPrefetching()

        let imageRequests = pages.map { ImageRequest(page: $0) }
        imagePrefetcher.startPrefetching(with: imageRequests)
    }
}
