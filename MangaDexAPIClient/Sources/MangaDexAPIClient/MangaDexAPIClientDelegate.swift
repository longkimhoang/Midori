//
//  MangaDexAPIClientDelegate.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get

final class MangaDexAPIClientDelegate: APIClientDelegate {
    func client(
        _: APIClient,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task _: URLSessionTask
    ) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw MangaDexAPIError(response: response, data: data)
        }
    }
}
