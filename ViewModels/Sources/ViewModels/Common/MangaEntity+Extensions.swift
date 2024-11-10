//
//  MangaEntity+Extensions.swift
//  Features
//
//  Created by Long Kim on 4/11/24.
//

import Dependencies
import MidoriStorage
import SwiftData

extension MangaEntity {
    var combinedAuthors: String? {
        guard let author else { return nil }
        @Dependency(\.locale) var locale
        return [author.name, artist?.name].compacted().uniqued()
            .formatted(.list(type: .and, width: .narrow).locale(locale))
    }
}
