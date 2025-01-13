//
//  Chapter.swift
//  ViewModels
//
//  Created by Long Kim on 7/1/25.
//

import Dependencies
import Foundation
import MidoriStorage

public struct Chapter: Identifiable, Equatable, Sendable {
    public struct GroupInfo: Equatable, Sendable {
        public let id: UUID
        public let name: String
    }

    public let id: UUID
    public let title: String
    public let groupInfo: GroupInfo?
    public let readableAt: String
}

extension Chapter {
    public var groupName: String {
        groupInfo?.name ?? String(localized: "No group", bundle: .module)
    }
}

extension Chapter {
    init(_ entity: ChapterEntity) {
        @Dependency(\.date.now) var now
        let format = Date.AnchoredRelativeFormatStyle(
            anchor: entity.readableAt,
            presentation: .numeric,
            capitalizationContext: .standalone
        )
        let readableAt = now.formatted(format)

        self.init(
            id: entity.id,
            title: entity.combinedTitle(includingVolume: false),
            groupInfo: entity.scanlationGroup.map { GroupInfo(id: $0.id, name: $0.name) },
            readableAt: readableAt
        )
    }
}
