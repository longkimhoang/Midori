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

    let manga: Manga
    let author: PartialAuthor
    let artist: PartialAuthor?
}

extension Manga {
    init(_ manga: MidoriModels.Manga) {
        let alternateTitles = manga.alternateTitles.map {
            let defaultVariant = $0.defaultVariant
            return AlternateTitle(
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
            authorID: manga.author.id,
            artistID: manga.artist?.id
        )
    }
}

extension MidoriModels.Manga {
    init(_ info: MangaInfo) {
        let manga = info.manga
        let author = info.author
        let artist = info.artist
        let alternateTitles = manga.alternateTitles.map { LocalizedString($0) }
        let description = manga.description.flatMap(LocalizedString.init)

        self.init(
            id: manga.id,
            title: manga.title,
            createdAt: manga.createdAt,
            followCount: manga.followCount,
            alternateTitles: alternateTitles,
            description: description,
            author: Author(author),
            artist: artist.map(Author.init)
        )
    }
}

private extension MidoriModels.Manga.Author {
    init(_ author: MangaInfo.PartialAuthor) {
        self.init(id: author.id, name: author.name)
    }
}

private extension LocalizedString {
    init(_ title: Manga.AlternateTitle) {
        self.init(defaultVariant: .init(languageCode: .init(title.language), value: title.value))
    }

    init?(_ dictionary: [String: String]) {
        let dictionary: [LanguageCode: String] = dictionary.reduce(into: [:]) { result, pair in
            result[LanguageCode(pair.key)] = pair.value
        }

        self.init(dictionary)
    }
}
