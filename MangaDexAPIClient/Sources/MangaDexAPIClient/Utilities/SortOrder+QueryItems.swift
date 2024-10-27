//
//  SortOrder+QueryItems.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation

extension Dictionary where Key: RawRepresentable<String>, Value == SortOrder {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "order[\($0.rawValue)]", value: $1.rawValue) }
    }
}
