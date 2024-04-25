//
//  Manga.swift
//
//
//  Created by Long Kim on 25/4/24.
//

import Foundation
import Models

public struct Manga: Equatable, Identifiable, Sendable {
  public let id: UUID
  public let name: LocalizedString
  public let description: LocalizedString?
}
