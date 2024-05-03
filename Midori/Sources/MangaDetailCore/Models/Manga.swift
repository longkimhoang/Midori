//
//  Manga.swift
//
//
//  Created by Long Kim on 3/5/24.
//

import Domain
import Foundation

public struct Manga: Equatable, Sendable {
  public let id: UUID
  public let title: LocalizedString
  public let description: LocalizedString?
  public let authorName: String
  public let artistName: String?
  public let coverImageURL: URL?
}
