//
//  Entity+Relationships.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Foundation

public extension Entity {
  /// Returns a relationship with the specified type, if available.
  func relationship<T: Relationship>(_: T.Type = T.self) -> T? {
    relationships.lazy.compactMap { $0 as? T }.first
  }
}
