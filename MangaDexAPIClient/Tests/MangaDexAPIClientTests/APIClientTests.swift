//
//  APIClientTests.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
import Get
import Testing

@testable import MangaDexAPIClient

@Suite struct APIClientTests {
    @Test(arguments: MangaDexServer.allCases)
    func clientHasCorrectBaseURL(server: MangaDexServer) async throws {
        let client = APIClient.mangaDex(server: server)
        let request = Request(path: "/test")
        let urlRequest = try await client.makeURLRequest(for: request)
        #expect(urlRequest.url?.absoluteString == "\(server.baseURL)/test")
    }
}
