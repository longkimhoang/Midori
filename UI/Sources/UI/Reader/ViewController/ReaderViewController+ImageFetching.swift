//
//  ReaderViewController+ImageFetching.swift
//  UI
//
//  Created by Long Kim on 15/11/24.
//

import MidoriViewModels
import Nuke

extension ReaderViewController {
    func imageRequest(for page: ReaderViewModel.Page, processors: [any ImageProcessing] = []) -> ImageRequest {
        ImageRequest(url: page.imageURL, processors: processors, userInfo: [.imageIdKey: page.id])
    }
}
