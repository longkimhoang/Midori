//
//  Manga.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import APICommon
import Foundation
import MetaCodable

@Codable
public struct Manga {
  public let id: UUID

  @CodedIn("attributes")
  @CodedBy(LocalizedStringCoder())
  public let title: LocalizedString

  @CodedIn("attributes")
  @CodedBy(LocalizedStringCoder())
  public let description: LocalizedString?

  @CodedBy(RelationshipCoder())
  public let relationships: [Reference]
}

extension Manga {
  public var author: Author? {
    relationships.lazy.compactMap(\.author).first
  }

  public var artist: Author? {
    relationships.lazy.compactMap(\.artist).first
  }
}

extension Manga: Identifiable {}
