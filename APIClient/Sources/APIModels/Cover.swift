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
  @CodedIn("attributes") public let locale: String
  @CodedIn("attributes") public let fileName: String
  @CodedIn("attributes") public let volume: String?
}
