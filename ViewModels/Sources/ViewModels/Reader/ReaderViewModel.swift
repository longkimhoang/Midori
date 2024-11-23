//
//  ReaderViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 12/11/24.
//

import Combine
import Dependencies
import Foundation
import IdentifiedCollections
import MidoriServices
import MidoriStorage

@MainActor
public final class ReaderViewModel {
    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.chapterService) private var chapterService

    public let chapterID: UUID
    @Published public var chapter: Chapter?
    @Published public var pages: IdentifiedArrayOf<Page> = []
    @Published public var controlsVisible: Bool = true

    public init(chapterID: UUID) {
        self.chapterID = chapterID
    }

    public func loadChapterFromStorage() throws {
        let context = modelContainer.mainContext

        let chapterEntity = try context.fetch(ChapterEntity.withID(chapterID)).first
        chapter = chapterEntity.flatMap(Chapter.init)
    }

    public func loadPagesFromStorage() throws {
        let context = modelContainer.mainContext

        let pageEntities = try context.fetch(PageEntity.withChapterID(chapterID, quality: .normal))
        pages = IdentifiedArray(uniqueElements: pageEntities.compactMap(Page.init))
    }

    public func fetchPages() async throws {
        try await chapterService.syncChapterPages(for: chapterID)
        try loadPagesFromStorage()
    }
}
