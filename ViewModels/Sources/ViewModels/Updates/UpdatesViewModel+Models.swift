//
//  UpdatesViewModel+Models.swift
//  ViewModels
//
//  Created by Long Kim on 7/1/25.
//

import Foundation
import IdentifiedCollections

extension UpdatesViewModel {
    public struct Section: Equatable, Sendable {
        public struct MangaInfo: Equatable, Sendable {
            public let id: UUID
            public let title: String
            public let coverImageURL: URL?
        }

        public let mangaInfo: MangaInfo
        public let chapters: IdentifiedArrayOf<Chapter>
    }
}

extension UpdatesViewModel.Section: Identifiable {
    public var id: UUID {
        mangaInfo.id
    }
}
