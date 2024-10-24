//
//  PersistenceContainer+Migration.swift
//  Storage
//
//  Created by Long Kim on 17/10/24.
//

import GRDB

extension PersistenceContainer {
    /// The `DatabaseMigrator` that defines the database schema.
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        #if DEBUG
            // Schema is still subject to change in development.
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("Create initial tables") { db in
            try db.create(table: "author") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text)
                t.column("imageUrl", .text)
            }

            try db.create(table: "manga") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text)
                t.column("createdAt", .datetime)
                t.column("alternateTitles", .jsonText)
                t.column("followCount", .integer)
                t.belongsTo("author")
                t.belongsTo("artist", inTable: "author")
            }

            try db.create(table: "mangaCover") { t in
                t.column("id", .text).primaryKey()
                t.column("fileName", .text)
                t.column("volume", .text)
                t.belongsTo("manga", onDelete: .cascade).notNull()
            }

            try db.alter(table: "manga") { t in
                t.add(column: "coverId", .text).references("mangaCover")
            }

            try db.create(table: "scanlationGroup") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .text)
            }

            try db.create(table: "chapter") { t in
                t.column("id", .text).primaryKey()
                t.column("volume", .text)
                t.column("title", .text)
                t.column("chapter", .text)
                t.column("readableAt", .datetime)
                t.belongsTo("manga", onDelete: .cascade).notNull()
                t.belongsTo("scanlationGroup", onDelete: .cascade)
            }

            try db.create(indexOn: "chapter", columns: ["volume", "chapter", "readableAt"])
        }

        return migrator
    }
}
