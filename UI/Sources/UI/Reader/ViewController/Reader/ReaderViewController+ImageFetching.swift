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
    func fetchImages(for pages: [ReaderViewModel.Page]) {
        imageLoadingTask?.cancel()
        imageLoadingTask = Task {
            await withDiscardingTaskGroup { group in
                for page in pages {
                    group.addTask { [unowned self] in
                        await fetchImage(for: page)
                    }
                }
            }
        }
    }

    func fetchImage(for page: ReaderViewModel.Page) async {
        let request = ImageRequest(page: page)
        let task = ImagePipeline.midoriReader.imageTask(with: request)
        await withTaskCancellationHandler {
            for await event in task.events {
                await MainActor.run { [weak self] in
                    self?.imageLoadingEvents[page.id] = event
                }
            }
        } onCancel: {
            task.cancel()
        }
    }
}
