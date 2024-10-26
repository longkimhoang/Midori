//
//  Manga+Adapters.swift
//  Storage
//
//  Created by Long Kim on 24/10/24.
//

import Foundation
import GRDB
import MidoriModels

struct MangaInfo: Decodable, FetchableRecord {
    struct PartialAuthor: Decodable {
        let id: UUID
        let name: String
    }

    let manga: MangaEntity
    let author: PartialAuthor
    let artist: PartialAuthor?
}

extension MangaEntity {
    init(_ manga: MidoriModels.Manga) {
        let alternateTitles = manga.alternateTitles.map {
            let defaultVariant = $0.defaultVariant
            return LocalizedTitle(
                language: defaultVariant.languageCode.rawValue,
                value: defaultVariant.value
            )
        }

        self.init(
            id: manga.id,
            title: manga.title,
            createdAt: manga.createdAt,
            alternateTitles: alternateTitles,
            followCount: manga.followCount,
            coverID: nil,
            authorID: manga.authorID,
            artistID: manga.artistID
        )
    }
}

extension MidoriModels.MangaOverview {
    init(_ info: MangaInfo) {
        let manga = info.manga
        let author = info.author
        let artist = info.artist
        let description = manga.description.flatMap(LocalizedString.init)

        self.init(
            id: manga.id,
            title: manga.title,
            description: description,
            author: author.name,
            artist: artist?.name
        )
    }
}

private extension LocalizedString {
    init(_ title: MangaEntity.LocalizedTitle) {
        self.init(defaultVariant: .init(languageCode: .init(title.language), value: title.value))
    }

    init?(_ dictionary: [String: String]) {
        let dictionary: [LanguageCode: String] = dictionary.reduce(into: [:]) { result, pair in
            result[LanguageCode(pair.key)] = pair.value
        }

        self.init(dictionary)
    }
}
