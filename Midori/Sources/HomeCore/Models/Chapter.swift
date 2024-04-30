//
//  Chapter.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Domain
import Foundation

public struct Chapter: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let title: String?
  public let chapter: String?
  public let volume: String?
  public let mangaTitle: LocalizedString
  public let coverImageURL: URL?

  public init(
    id: UUID,
    title: String?,
    chapter: String?,
    volume: String?,
    mangaTitle: LocalizedString,
    coverImageURL: URL?
  ) {
    self.id = id
    self.title = title
    self.chapter = chapter
    self.volume = volume
    self.mangaTitle = mangaTitle
    self.coverImageURL = coverImageURL
  }
}
