//
//  Home+Models.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import Foundation
import MidoriStorage

public extension Home {
    struct PopularManga: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let title: String
        public let author: String
        public let artist: String?
    }
}

extension Home.PopularManga {
    init?(_ entity: MangaEntity) {
        guard let author = entity.author else {
            return nil
        }

        self.init(
            id: entity.id,
            title: entity.title,
            author: author.name,
            artist: entity.artist?.name
        )
    }
}
