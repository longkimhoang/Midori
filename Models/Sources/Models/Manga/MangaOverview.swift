//
//  MangaOverview.swift
//  Models
//
//  Created by Long Kim on 25/10/24.
//

import Foundation

public struct MangaOverview: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let description: LocalizedString?
    public let author: String
    public let artist: String?

    public init(
        id: UUID,
        title: String,
        description: LocalizedString? = nil,
        author: String,
        artist: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.author = author
        self.artist = artist
    }
}
