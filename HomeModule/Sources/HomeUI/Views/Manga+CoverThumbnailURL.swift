//
//  Manga+CoverThumbnailURL.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Foundation
import Persistence

extension Manga {
  var coverThumbnailURL: URL? {
    guard let coverImageURL = coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".256.jpg")
  }
}
