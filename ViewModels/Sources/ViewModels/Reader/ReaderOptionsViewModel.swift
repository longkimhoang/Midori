//
//  ReaderOptionsViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 17/12/24.
//

import Foundation

@MainActor
public final class ReaderOptionsViewModel: ObservableObject {
    public enum TransitionStyle: CaseIterable, Sendable {
        case scroll
        case pageCurl
    }

    @Published public var useRightToLeftLayout: Bool = false
    @Published public var transitionStyle: TransitionStyle = .scroll

    public init() {}
}

public extension ReaderOptionsViewModel.TransitionStyle {
    var label: String {
        switch self {
        case .scroll:
            String(localized: "Scroll", bundle: .module)
        case .pageCurl:
            String(localized: "Page curl", bundle: .module)
        }
    }
}
