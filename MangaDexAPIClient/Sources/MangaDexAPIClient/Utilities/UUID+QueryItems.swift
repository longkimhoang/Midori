//
//  UUID+QueryItems.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 2/11/24.
//

import Foundation

extension Collection<UUID> {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "ids[]", value: $0.uuidString.lowercased()) }
    }
}
