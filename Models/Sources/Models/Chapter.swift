//
//  Chapter.swift
//  Models
//
//  Created by Long Kim on 7/1/25.
//

import Foundation

public struct Chapter: Equatable, Identifiable {
    public let id: UUID
    public let volume: Volume
    public let title: String?
    public let chapter: String?
    public let readableAt: Date

    public init(id: UUID, volume: Volume, title: String?, chapter: String?, readableAt: Date) {
        self.id = id
        self.volume = volume
        self.title = title
        self.chapter = chapter
        self.readableAt = readableAt
    }
}
