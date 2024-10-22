//
//  PersistenceContainer.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import Dependencies
import Foundation
import GRDB

/// A container that encapsulates the storage stack of the app.
public final class PersistenceContainer: Sendable {
    let dbWriter: any DatabaseWriter

    /// - Parameter inMemory: Whether the stack is created in memory without persistence. Useful for
    /// previews and testing.
    init(_ dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
        try! migrator.migrate(dbWriter)
    }

    /// A read only view of the database.
    var dbReader: DatabaseReader { dbWriter }
}

// MARK: - Dependency

private enum PersistenceContainerDependencyKey: DependencyKey {
    static var testValue: PersistenceContainer {
        // We don't want a singleton here, hence the computed variable.
        // This way, tests can run in parallel as each test case can spawn its own in-memory DB.
        let dbQueue = try! DatabaseQueue()
        return PersistenceContainer(dbQueue)
    }

    static let liveValue: PersistenceContainer = {
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appending(components: "Database", "Midori.sqlite")

        let dbPool = try! DatabasePool(path: url.path)
        return PersistenceContainer(dbPool)
    }()
}

public extension DependencyValues {
    /// A `ModelContainer` instance describing the models the app defines.
    var persistenceContainer: PersistenceContainer {
        get { self[PersistenceContainerDependencyKey.self] }
        set { self[PersistenceContainerDependencyKey.self] = newValue }
    }
}
