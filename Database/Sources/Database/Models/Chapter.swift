//
//  Chapter.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Foundation
import SwiftData

@Model
public final class Chapter {
  // MARK: - Attributes

  @Attribute(.unique)
  public var chapterID: UUID
  public var volume: String?
  public var title: String?
  public var chapter: String?
  public var readableAt: Date

  // MARK: - Relationships

  @Relationship
  public var manga: Manga?

  // MARK: - Initializers

  public init(
    chapterID: UUID,
    volume: String? = nil,
    title: String? = nil,
    chapter: String? = nil,
    readableAt: Date
  ) {
    self.chapterID = chapterID
    self.volume = volume
    self.title = title
    self.chapter = chapter
    self.readableAt = readableAt
  }
}
