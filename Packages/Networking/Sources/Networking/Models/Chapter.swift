//
//  Chapter.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Foundation
import HelperCoders
import MetaCodable

@Codable
public struct Chapter: Entity {
  @Codable
  public struct Attributes: Sendable {
    public let title: String?
    public let volume: String?
    /// A `nil` usually indicates a oneshot, but ``title`` might provide more context.
    public let chapter: String?
    /// Count of readable images for this chapter
    public let pages: Int
    /// Denotes a chapter that links to an external source.
    @CodedAt("externalUrl") public let externalURL: URL?
    public let version: Int
    public let readableAt: Date
  }

  public let id: UUID
  public let attributes: Attributes
  @CodedBy(SequenceCoder(elementHelper: RelationshipCoder(), configuration: .lossy))
  public let relationships: [any Relationship]

  public init(id: UUID, attributes: Attributes) {
    self.id = id
    self.attributes = attributes
    relationships = []
  }
}
