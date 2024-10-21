//
//  Pagination.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct Pagination: Equatable, Sendable {
    public let limit: Int
    public let offset: Int

    public init(limit: Int, offset: Int = 0) {
        self.limit = limit
        self.offset = offset
    }
}

extension Pagination {
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if limit > 0 {
            items.append(.init(name: "limit", value: String(limit)))
        }
        if offset > 0 {
            items.append(.init(name: "offset", value: String(offset)))
        }
        return items
    }
}
