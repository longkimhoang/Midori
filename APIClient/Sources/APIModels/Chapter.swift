//
//  Chapter.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Foundation
import HelperCoders
import MetaCodable

@Codable
@MemberInit
public struct Chapter {
  public typealias Attributes = ChapterAttributes

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(SequenceCoder(elementHelper: RelationshipCoder()))
  public let relationships: [Relationship]

  public init(id: UUID, attributes: Attributes) {
    self.init(id: id, attributes: attributes, relationships: [])
  }
}

@Codable
public struct ChapterAttributes {
  public let title: String?
  public let volume: String?
  public let chapter: String?
  /// Count of readable images for this chapter
  public let pages: Int
  /// Denotes a chapter that links to an external source.
  @CodedAt("externalUrl") public let externalURL: URL?
  public let version: Int
}

extension Chapter: Identifiable {}
