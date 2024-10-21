//
//  JSONDecoder+MangaDexAPI.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

extension JSONDecoder {
    static var mangaDexAPI: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            return try Date(dateString, strategy: .mangaDexAPIDate)
        }
        return decoder
    }
}
