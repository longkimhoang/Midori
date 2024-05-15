//
//  Chapter.swift
//
//
//  Created by Long Kim on 16/5/24.
//

import Foundation

public struct Chapter: Equatable, Sendable {
  public let pages: [Page]
  public let dataSaverPages: [Page]

  public init(pages: [Page], dataSaverPages: [Page]) {
    self.pages = pages
    self.dataSaverPages = dataSaverPages
  }
}
