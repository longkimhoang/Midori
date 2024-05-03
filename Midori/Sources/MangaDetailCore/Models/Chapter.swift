//
//  Chapter.swift
//
//
//  Created by Long Kim on 3/5/24.
//

import Foundation

public struct Chapter: Identifiable, Equatable, Sendable {
  public let id: UUID
  public let title: String?
  public let chapter: String?
  public let volume: String?
  public let readableAt: Date
  public let scanlatorGroup: String
}
