//
//  Cover.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import MetaCodable

@Codable
public struct Cover {
  public typealias Attributes = CoverAttributes

  public let id: UUID
  public let attributes: Attributes
}

@Codable
public struct CoverAttributes {
  public let locale: String
  public let fileName: String
  public let volume: String?
}
