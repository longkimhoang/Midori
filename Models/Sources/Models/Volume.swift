//
//  Volume.swift
//  Models
//
//  Created by Long Kim on 7/1/25.
//

public enum Volume: Equatable {
    case none
    case named(String)
}

extension Volume: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        /// In the context of a manga, `none` means an unreleased volume, thus has the highest order.
        switch (lhs, rhs) {
        case (.none, .none):
            false
        case (.named, .none):
            true
        case (.none, .named):
            false
        case let (.named(lhs), .named(rhs)):
            lhs < rhs
        }
    }
}
