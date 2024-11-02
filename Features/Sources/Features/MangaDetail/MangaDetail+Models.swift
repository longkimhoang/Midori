//
//  MangaDetail+Models.swift
//  Features
//
//  Created by Long Kim on 1/11/24.
//

import MidoriStorage

public extension MangaDetail {
    struct Manga: Equatable, Sendable {
        let title: String
        let alternateTitle: String?
    }
}

extension MangaDetail.Manga {
    init(_ entity: MangaEntity) {
        let alternateTitle = entity.alternateTitles.lazy.compactMap { $0.localizedVariants["en"] }.first

        self.init(
            title: entity.title,
            alternateTitle: alternateTitle
        )
    }
}
