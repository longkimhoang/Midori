//
//  Manga.swift
//
//
//  Created by Long Kim on 23/4/24.
//

import Foundation

public struct Manga: Decodable {
  public struct Attributes: Decodable {
    public let title: LocalizedString
    public let description: LocalizedString?
    public let createdAt: Date
  }

  public let id: UUID
}
