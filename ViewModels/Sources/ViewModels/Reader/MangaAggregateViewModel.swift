//
//  MangaAggregateViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 15/12/24.
//

import Foundation

@MainActor
public final class MangaAggregateViewModel: Identifiable {
    public let aggregate: ReaderViewModel.Aggregate
    @Published public var selectedChapter: UUID

    public init(aggregate: ReaderViewModel.Aggregate, selectedChapter: UUID) {
        self.aggregate = aggregate
        self.selectedChapter = selectedChapter
    }
}
