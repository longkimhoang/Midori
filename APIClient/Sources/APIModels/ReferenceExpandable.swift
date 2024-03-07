//
//  ReferenceExpandable.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Foundation

/// A type that can be expanded to a complete entity.
public protocol ReferenceExpandable<Attributes> {
  associatedtype Attributes: Codable

  var id: UUID { get }
  var attributes: Attributes { get }

  init(id: UUID, attributes: Attributes)
}

extension Manga: ReferenceExpandable {}
extension Chapter: ReferenceExpandable {}
extension Author: ReferenceExpandable {}
extension Cover: ReferenceExpandable {}
