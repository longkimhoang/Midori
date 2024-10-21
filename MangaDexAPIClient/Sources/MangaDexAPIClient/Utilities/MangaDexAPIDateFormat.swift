//
//  MangaDexAPIDateFormat.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation

struct MangaDexAPIDateFormat {
    private let implementation: Date.ISO8601FormatStyle

    init() {
        implementation = Date.ISO8601FormatStyle().year().month().day()
            .time(includingFractionalSeconds: false)
    }
}

extension MangaDexAPIDateFormat: FormatStyle {
    typealias FormatInput = Date
    typealias FormatOutput = String

    func format(_ value: Date) -> String {
        implementation.format(value)
    }
}

extension MangaDexAPIDateFormat: ParseStrategy {
    typealias ParseInput = String
    typealias ParseOutput = Date

    func parse(_ value: String) throws -> Date {
        try implementation.parse(value)
    }
}

extension FormatStyle where Self == MangaDexAPIDateFormat {
    static var mangaDexAPIDate: Self { .init() }
}

extension ParseStrategy where Self == MangaDexAPIDateFormat {
    static var mangaDexAPIDate: Self { .init() }
}
