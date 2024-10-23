//
//  Manga+Adapters.swift
//  Storage
//
//  Created by Long Kim on 24/10/24.
//

import Foundation
import GRDB
import MidoriModels

// MARK: - Manga Info

struct MangaInfo: Decodable, FetchableRecord {
    struct PartialAuthor: Decodable {
        let id: UUID
        let name: String
    }

    let manga: Manga
    let author: PartialAuthor
    let artist: PartialAuthor?
}

extension MidoriModels.Manga {
    init(_ info: MangaInfo) {
        let manga = info.manga
        let author = info.author
        let artist = info.artist

        self.init(
            id: manga.id,
            title: manga.title,
            author: .init(author),
            artist: artist.map { .init($0) }
        )
    }
}

private extension MidoriModels.Manga.Author {
    init(_ author: MangaInfo.PartialAuthor) {
        self.init(id: author.id, name: author.name)
    }
}
