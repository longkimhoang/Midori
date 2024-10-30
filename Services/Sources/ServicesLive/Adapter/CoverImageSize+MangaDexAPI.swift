//
//  CoverImageSize+MangaDexAPI.swift
//  Services
//
//  Created by Long Kim on 30/10/24.
//

import MangaDexAPIClient
import MidoriStorage

extension MangaCoverEntity.ImageSize {
    init(_ apiModel: Manga.ImageSize) {
        switch apiModel {
        case .original:
            self = .original
        case .small:
            self = .smallThumbnail
        case .medium:
            self = .mediumThumbnail
        }
    }
}
