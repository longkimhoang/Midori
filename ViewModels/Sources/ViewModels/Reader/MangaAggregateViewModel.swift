//
//  MangaAggregateViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 15/12/24.
//

import Foundation

@Observable
@MainActor public final class MangaAggregateViewModel: Identifiable {
    public let aggregate: ReaderViewModel.Aggregate
    public var selectedChapter: UUID

    public init(aggregate: ReaderViewModel.Aggregate, selectedChapter: UUID) {
        self.aggregate = aggregate
        self.selectedChapter = selectedChapter
    }
}
