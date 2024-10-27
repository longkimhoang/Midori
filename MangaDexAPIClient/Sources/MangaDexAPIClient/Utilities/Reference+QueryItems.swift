//
//  Reference+QueryItems.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 27/10/24.
//

import Foundation

protocol EndpointReference: RawRepresentable where RawValue == String {}

extension Collection where Element: EndpointReference {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: "includes[]", value: $0.rawValue) }
    }
}
