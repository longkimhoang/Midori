//
//  UUID+QueryItems.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 2/11/24.
//

import Foundation

extension Collection<UUID> {
    func queryItems(name: String = "ids[]") -> [URLQueryItem] {
        map { URLQueryItem(name: name, value: $0.uuidString.lowercased()) }
    }
}
