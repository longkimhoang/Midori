//
//  Chapter.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Foundation

public struct Chapter: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let title: String?
  public let chapter: String?
  public let volume: String?
  public let mangaTitle: String
}
