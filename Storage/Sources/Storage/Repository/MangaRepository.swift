//
//  MangaRepository.swift
//  Storage
//
//  Created by Long Kim on 22/10/24.
//

import Combine
import Dependencies
import DependenciesMacros

@DependencyClient
public struct MangaRepository: Sendable {
    public var fetchPopularMangas: @Sendable () -> any StorageValuePublisher<[Manga]> = {
        EmptyStorageValuePublisher()
    }
}

extension MangaRepository: TestDependencyKey {
    public static let testValue = Self()
}

public extension DependencyValues {
    var mangaRepository: MangaRepository {
        get { self[MangaRepository.self] }
        set { self[MangaRepository.self] = newValue }
    }
}
