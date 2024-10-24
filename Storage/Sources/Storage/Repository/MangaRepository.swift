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

    public var fetchPopularMangas: @Sendable () -> StorageValuePublisher<[MangaOverview]> = {
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

                let author = MangaEntity.author.select(Column("name").forKey("author"))
                let artist = MangaEntity.artist.select(Column("name").forKey("artist"))

                return try MangaEntity
                    .filter(Column("createdAt") >= lastMonth)
                    .order(Column("followCount"))
                    .limit(10)
                    .annotated(withRequired: author)
                    .annotated(withOptional: artist)
                    .asRequest(of: MangaInfo.self)
                    .fetchAll(db)
            }
            .map { $0.map(MangaOverview.init) }
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
