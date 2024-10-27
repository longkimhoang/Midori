//
//  Manga+Stubs.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation

public extension MangaDexAPIStubs {
    enum Manga {}
}

// MARK: - Get Manga list

public extension MangaDexAPIStubs.Manga {
    enum List {
        public static let success = Data.fromJSONFile(named: "get_manga_list")
    }
}
