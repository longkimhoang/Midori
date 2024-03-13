//
//  Manga+CoverThumbnailURL.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Database
import Foundation
import SwiftData

extension Manga {
  var coverThumbnailURL: URL? {
    coverImageURL.flatMap { URL(string: $0.absoluteString + ".256.jpg") }
  }
}
