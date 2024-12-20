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
