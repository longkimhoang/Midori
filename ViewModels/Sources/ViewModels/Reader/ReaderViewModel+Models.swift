//
//  ReaderViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 14/11/24.
//

import Foundation
import MidoriStorage

public extension ReaderViewModel {
    struct Page: Identifiable, Equatable {
        public let id: String
        public let imageURL: URL

        public init(id: String, imageURL: URL) {
            self.id = id
            self.imageURL = imageURL
        }
    }
}

public extension ReaderViewModel.Page {
    init?(_ entity: PageEntity) {
        guard let chapter = entity.chapter else {
            return nil
        }

        let id = "chapterID=\(chapter.id);page=\(entity.pageIndex);quality=\(entity.quality.rawValue)"
        self.init(id: id, imageURL: entity.imageURL)
    }
}
