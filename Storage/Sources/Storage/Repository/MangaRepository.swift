//
//  MangaRepository.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Dependencies
import DependenciesMacros
import Foundation
import GRDB
import MidoriModels

@DependencyClient
public struct MangaRepository: Sendable {
    public typealias Manga = MidoriModels.Manga

    public var fetchPopularMangas: @Sendable () -> StorageValuePublisher<[Manga]> = {
        EmptyStorageValuePublisher()
    }
}

extension MangaRepository: DependencyKey {
    private typealias MangaEntity = Storage.Manga

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

                let author = MangaEntity.author.select(Column("id"), Column("name"))
                let artist = MangaEntity.artist.select(Column("id"), Column("name"))

                return try MangaEntity
                    .filter(Column("createdAt") >= lastMonth)
                    .limit(10)
                    .including(required: author)
                    .including(optional: artist)
                    .asRequest(of: MangaInfo.self)
                    .fetchAll(db)
            }
            .map { $0.map(Manga.init) }
        }
    )

    public static let testValue = Self()
}

public extension DependencyValues {
    var mangaRepository: MangaRepository {
        get { self[MangaRepository.self] }
        set { self[MangaRepository.self] = newValue }
    }
}
