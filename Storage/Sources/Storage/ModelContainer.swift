//
//  ModelContainer.swift
//  Storage
//
//  Created by Long Kim on 26/10/24.
//

import Dependencies
import SwiftData

extension ModelContainer {
    fileprivate static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([MangaEntity.self, UserEntity.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: configuration)
    }
}

private enum ModelContainerDependencyKey: DependencyKey {
    typealias Value = ModelContainer

    static var testValue: ModelContainer {
        try! ModelContainer.make(inMemory: true)
    }

    static let liveValue = try! ModelContainer.make()
}

extension DependencyValues {
    public var modelContainer: ModelContainer {
        get { self[ModelContainerDependencyKey.self] }
        set { self[ModelContainerDependencyKey.self] = newValue }
    }
}
