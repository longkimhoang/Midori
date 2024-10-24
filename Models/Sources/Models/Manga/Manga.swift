//
//  Manga.swift
//  Models
//
//  Created by Long Kim on 24/10/24.
//

import Foundation

public struct Manga: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let alternateTitles: [LocalizedString]
    public let description: LocalizedString?

    public init(
        id: UUID,
        title: String,
        alternateTitles: [LocalizedString] = [],
        description: LocalizedString? = nil
    ) {
        self.id = id
        self.title = title
        self.alternateTitles = alternateTitles
        self.description = description
    }
}
