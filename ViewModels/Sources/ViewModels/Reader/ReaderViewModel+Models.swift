//
//  ReaderViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 14/11/24.
//

import Foundation
import MidoriStorage

public extension ReaderViewModel {
    struct Chapter: Equatable {
        public let title: String
        public let manga: String

        public init(title: String, manga: String) {
            self.title = title
            self.manga = manga
        }
    }

    struct Page: Identifiable, Equatable {
        public let id: String
        public let imageURL: URL

        public init(id: String, imageURL: URL) {
            self.id = id
            self.imageURL = imageURL
        }
    }
}

public extension ReaderViewModel.Chapter {
    init?(_ entity: ChapterEntity) {
        guard let manga = entity.manga else {
            return nil
        }

        title = switch (entity.chapter, entity.title) {
        case let (.some(chapter), _):
            String(localized: "Chapter \(chapter)", bundle: .module)
        case let (.none, .some(title)):
            title
        default:
            String(localized: "Oneshot", bundle: .module)
        }
        self.manga = manga.title
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
