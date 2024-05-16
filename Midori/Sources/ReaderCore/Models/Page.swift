//
//  Page.swift
//
//
//  Created by Long Kim on 16/5/24.
//

import Foundation

public struct Page: Equatable, Sendable {
  public let chapterID: UUID
  public let pageNumber: Int
  public let url: URL

  public init(chapterID: UUID, pageNumber: Int, url: URL) {
    self.chapterID = chapterID
    self.pageNumber = pageNumber
    self.url = url
  }
}
