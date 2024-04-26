//
//  Chapter.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Foundation
import SwiftData

@Model
public final class Chapter {
  @Attribute(.unique) public var chapterID: UUID
  public var volume: String?
  public var title: String?
  public var chapter: String?
  public var readableAt: Date

  public init(
    chapterID: UUID = .init(),
    volume: String? = nil,
    title: String? = nil,
    chapter: String? = nil,
    readableAt: Date = .now
  ) {
    self.chapterID = chapterID
    self.volume = volume
    self.title = title
    self.chapter = chapter
    self.readableAt = readableAt
  }

  // MARK: Relationships

  @Relationship public var manga: Manga?
}
