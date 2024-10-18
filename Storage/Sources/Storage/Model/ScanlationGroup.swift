//
//  ScanlationGroup.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Foundation
import GRDB

public struct ScanlationGroup: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String?

    public init(id: UUID, name: String, description: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
    }
}

extension ScanlationGroup: FetchableRecord, PersistableRecord {
    private static let chapters = hasMany(Chapter.self)

    /// The chapters this group worked on.
    public var chapters: QueryInterfaceRequest<Chapter> {
        request(for: ScanlationGroup.chapters)
    }
}
