//
//  MangaDexAPIError.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

public struct MangaDexAPIError: Error {
    public struct ErrorDetail: Decodable, Sendable {
        public let id: UUID
        public let status: Int
        public let title: String
        public let detail: String?
        public let context: String?
    }

    public let status: Int
    public let details: [ErrorDetail]

    public init(status: Int, details: [ErrorDetail] = []) {
        self.status = status
        self.details = details
    }
}

extension MangaDexAPIError {
    private enum Result: String, Decodable {
        case error
    }

    private struct DecodableError: Decodable {
        let result: Result
        let errors: [ErrorDetail]
    }

    init(response: HTTPURLResponse, data: Data) {
        status = response.statusCode
        do {
            let decodableError = try JSONDecoder().decode(DecodableError.self, from: data)
            details = decodableError.errors
        } catch {
            details = []
        }
    }
}
