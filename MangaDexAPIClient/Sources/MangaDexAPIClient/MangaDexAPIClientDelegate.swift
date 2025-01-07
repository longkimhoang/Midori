//
//  MangaDexAPIClientDelegate.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Dependencies
import Foundation
import Get
import MangaDexAuth

final class MangaDexAPIClientDelegate: APIClientDelegate {
    @Dependency(\.authenticationRequestDecorator) private var authenticationRequestDecorator

    func client(
        _: APIClient,
        validateResponse response: HTTPURLResponse,
        data: Data,
        task _: URLSessionTask
    ) throws {
        guard (200..<300).contains(response.statusCode) else {
            throw MangaDexAPIError(response: response, data: data)
        }
    }

    func client(_: APIClient, willSendRequest request: inout URLRequest) async throws {
        try await authenticationRequestDecorator.decorate(&request)
    }
}
