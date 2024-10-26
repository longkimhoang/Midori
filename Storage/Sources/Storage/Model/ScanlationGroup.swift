//
//  ScanlationGroup.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Foundation
import SwiftData

@Model
public final class ScanlationGroupEntity {
    #Unique<ScanlationGroupEntity>([\.id])

    public var id: UUID
    public var name: String
    public var groupDescription: String?

    public init(id: UUID, name: String, groupDescription: String? = nil) {
        self.id = id
        self.name = name
        self.groupDescription = groupDescription
    }

    @Relationship public var chapters: [ChapterEntity] = []
}
