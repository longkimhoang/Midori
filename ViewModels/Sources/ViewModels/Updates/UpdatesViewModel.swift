//
//  UpdatesViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 2/1/25.
//

import Dependencies
import Foundation
import MidoriServices

@MainActor
public final class UpdatesViewModel: ObservableObject {
    @Dependency(\.mangaService) private var mangaService: MangaService

    public init() {}

    public func loadFeedFromStorage() {}
}
