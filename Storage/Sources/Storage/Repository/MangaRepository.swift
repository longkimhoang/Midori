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
    public var fetchPopularMangas: @Sendable () -> StorageValuePublisher<[MangaInfo]> = {
        EmptyStorageValuePublisher()
    }
}

extension MangaRepository: DependencyKey {
    public static let liveValue = Self(
        fetchPopularMangas: {
            @Dependency(\.calendar) var calendar
            @Dependency(\.date.now) var now

            return GRDBStorageValuePublisher { db in
                let lastMonth = calendar.date(
                    byAdding: .month,
                    value: -1,
                    to: now,
                    wrappingComponents: false
                )

                return try Manga
                    .select(Column("id"), Column("title"), Column("createdAt"))
                    .filter(Column("createdAt") >= lastMonth)
                    .limit(10)
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
