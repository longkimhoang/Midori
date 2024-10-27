//
//  Data+JSON.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation

extension Data {
    static func fromJSONFile(named file: String) -> Data {
        guard let url = Bundle.module.url(forResource: "get_manga_list", withExtension: "json")
        else {
            fatalError("Stub file not found: \(file)")
        }

        return try! Data(contentsOf: url)
    }
}
