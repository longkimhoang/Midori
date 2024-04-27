//
//  Manga+CoverImageURL.swift
//
//
//  Created by Long Kim on 27/4/24.
//

import Foundation

public extension Manga {
  internal static let coverBaseURL = URL(string: "https://uploads.mangadex.org/covers")!

  enum ThumbnailSize: Int {
    case small = 256
    case medium = 512
  }

  var coverImageURL: URL? {
    guard let cover else { return nil }
    return Manga.coverBaseURL.appending(components: mangaID.uuidString.lowercased(), cover.fileName)
  }

  func coverThumbnailImageURL(for size: ThumbnailSize) -> URL? {
    guard let coverImageURL else { return nil }
    return URL(string: coverImageURL.absoluteString + ".\(size.rawValue).jpg")
  }
}
