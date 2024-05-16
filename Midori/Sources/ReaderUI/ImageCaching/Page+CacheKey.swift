//
//  Page+CacheKey.swift
//
//
//  Created by Long Kim on 16/5/24.
//

import ReaderCore

extension Page {
  /// The key used to cache the page image.
  var cacheKey: String {
    "page:\(chapterID):\(pageNumber)"
  }
}
