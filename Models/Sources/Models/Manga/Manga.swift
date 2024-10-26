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
    public let createdAt: Date
    public let followCount: Int
    public let alternateTitles: [LocalizedString]
    public let description: LocalizedString?
    public let authorID: UUID
    public let artistID: UUID?

    public init(
        id: UUID,
        title: String,
        createdAt: Date,
        followCount: Int,
        alternateTitles: [LocalizedString] = [],
        description: LocalizedString? = nil,
        authorID: UUID,
        artistID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.followCount = followCount
        self.alternateTitles = alternateTitles
        self.description = description
        self.authorID = authorID
        self.artistID = artistID
    }
}
