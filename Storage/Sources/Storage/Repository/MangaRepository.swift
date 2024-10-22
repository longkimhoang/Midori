//
//  MangaRepository.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Dependencies
import DependenciesMacros
import GRDB
import MidoriModels

@DependencyClient
public struct MangaRepository: Sendable {
    public var fetchPopularMangas: @Sendable () -> any StorageValuePublisher<[MangaInfo]> = {
        EmptyStorageValuePublisher()
    }
}

extension MangaRepository: DependencyKey {
    public static let liveValue = Self(
        fetchPopularMangas: {
            GRDBStorageValuePublisher { db in
                @Dependency(\.calendar) var calendar
                @Dependency(\.date) var date

                let lastMonth = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: date(),
                    wrappingComponents: false
                )

                return try Manga
                    .filter(Column("createdAt") >= lastMonth)
                    .limit(10)
                    .select(Column("id"), Column("title"))
                    .including(required: Manga.author.select(Column("id"), Column("name")))
                    .including(optional: Manga.artist.select(Column("id"), Column("name")))
                    .asRequest(of: MangaInfo.self)
                    .fetchAll(db)
            }
        }
    )

    public static let testValue = Self()
}

extension MangaInfo: @retroactive FetchableRecord {}

public extension DependencyValues {
    var mangaRepository: MangaRepository {
        get { self[MangaRepository.self] }
        set { self[MangaRepository.self] = newValue }
    }
}
