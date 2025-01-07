//
//  Manga+Stubs.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation

extension MangaDexAPIStubs {
    public enum Manga {}
}

// MARK: - Get Manga list

extension MangaDexAPIStubs.Manga {
    public enum List {
        public static let success = Data.fromJSONFile(named: "get_manga_list")
    }
}
