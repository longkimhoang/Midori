//
//  Manga.swift
//  Models
//
//  Created by Long Kim on 24/10/24.
//

import Foundation

public struct Manga: Identifiable, Equatable, Sendable {
    public struct Author: Equatable, Sendable {
        public let id: UUID
        public let name: String

        public init(id: UUID, name: String) {
            self.id = id
            self.name = name
        }
    }

    public let id: UUID
    public let title: String
    public let alternateTitles: [LocalizedString]
    public let description: LocalizedString?
    public let author: Author
    public let artist: Author?

    public init(
        id: UUID,
        title: String,
        alternateTitles: [LocalizedString] = [],
        description: LocalizedString? = nil,
        author: Author,
        artist: Author? = nil
    ) {
        self.id = id
        self.title = title
        self.alternateTitles = alternateTitles
        self.description = description
        self.author = author
        self.artist = artist
    }
}
