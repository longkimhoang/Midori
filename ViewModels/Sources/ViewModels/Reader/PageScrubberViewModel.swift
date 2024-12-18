//
//  PageScrubberViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 19/12/24.
//

import Foundation

@MainActor
public final class PageScrubberViewModel: ObservableObject {
    @Published public var currentPage: Int = 1
    @Published public var numberOfPages: Int = 1

    public init() {}
}
