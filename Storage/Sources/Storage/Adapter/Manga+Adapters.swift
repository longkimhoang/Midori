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
    let manga: Manga
    let author: String
    let artist: String?
}

extension MidoriModels.MangaOverview {
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
