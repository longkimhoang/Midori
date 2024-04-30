//
//  Relationships.swift
//  Networking
//
//  Created by Long Kim on 30/4/24.
//

import Foundation

/// A container for relationships that allows for decoding from an external representation.
public struct Relationships: Decodable, Sendable {
  let relationships: [any Relationship]

  init(relationships: [any Relationship] = []) {
    self.relationships = relationships
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.unkeyedContainer()
    var relationships: [any Relationship] = []
    while !container.isAtEnd {
      let decoder = try container.superDecoder()
      do {
        try relationships.append(RelationshipCoder().decode(from: decoder))
      } catch {
        // There may be relationship types we don't know about.
        continue
      }
    }

    self.relationships = relationships
  }
}

// MARK: - RandomAccessCollection

extension Relationships: RandomAccessCollection {
  public typealias Element = any Relationship
  public typealias Index = Int

  public var startIndex: Int { relationships.startIndex }
  public var endIndex: Int { relationships.endIndex }

  public func index(before i: Int) -> Int {
    relationships.index(before: i)
  }

  public func index(after i: Int) -> Int {
    relationships.index(after: i)
  }

  public subscript(position: Int) -> any Relationship {
    relationships[position]
  }
}
