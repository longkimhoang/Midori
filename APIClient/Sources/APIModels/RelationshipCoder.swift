//
//  RelationshipCoder.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import MetaCodable

struct RelationshipCoder: HelperCoder {
  typealias Coded = [Reference]

  func decode(from decoder: Decoder) throws -> [Reference] {
    var container = try decoder.unkeyedContainer()
    var references: [Reference] = []

    while !container.isAtEnd {
      do {
        let reference = try container.decode(Reference.self)
        references.append(reference)
      } catch {
        // It's likely a type that we don't know how to decode yet, so just skip them.
        _ = try container.decode(InvalidValue.self)
      }
    }

    return references
  }

  // We use this to allow the container to skip decoding this value.
  // Since this will always succeed.
  private struct InvalidValue: Codable {}
}
