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
import Observation

@Observable
@MainActor public final class ReaderViewModel {
    @ObservationIgnored @Dependency(\.modelContainer) private var modelContainer
    @ObservationIgnored @Dependency(\.chapterService) private var chapterService
    @ObservationIgnored @Dependency(\.mangaService) private var mangaService

    public var chapterID: UUID
    public var chapter: Chapter?
    public var pages: IdentifiedArrayOf<Page> = []
    public var aggregate: Aggregate?
    public var controlsVisible: Bool = true

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
        let pages = IdentifiedArray(uniqueElements: pageEntities.compactMap(Page.init))

        guard pages != self.pages else {
            return
        }

        self.pages = pages
    }

    public func fetchPages() async throws {
        try await chapterService.syncChapterPages(for: chapterID)
        try loadPagesFromStorage()
    }

    public func loadAggregateFromStrorage() throws {
        guard let chapter else {
            return
        }

        let context = modelContainer.mainContext
        let mangaID = chapter.manga.id
        let scanlationGroupID = chapter.scanlationGroup.id
        let fetchDescriptor = MangaAggregateEntity.withMangaID(mangaID, scanlationGroupID: scanlationGroupID)

        aggregate = try context.fetch(fetchDescriptor).first.flatMap(Aggregate.init)
    }

    public func fetchAggregate() async throws {
        guard let chapter else {
            return
        }

        let mangaID = chapter.manga.id
        let scanlationGroupID = chapter.scanlationGroup.id
        try await mangaService.syncMangaAggregate(mangaID: mangaID, scanlationGroupID: scanlationGroupID)
        try loadAggregateFromStrorage()
    }

    public var nextChapter: Aggregate.Chapter? {
        guard let aggregate else {
            return nil
        }

        for volume in aggregate.volumes {
            guard var chapterIndex = volume.chapters.index(id: chapterID) else {
                continue
            }

            volume.chapters.formIndex(after: &chapterIndex)
            guard chapterIndex < volume.chapters.endIndex else {
                continue
            }

            return volume.chapters[chapterIndex]
        }

        return nil
    }

    public func switchChapter(to chapterID: UUID) async {
        self.chapterID = chapterID

        do {
            try loadChapterFromStorage()
            try loadPagesFromStorage()

            try await withThrowingDiscardingTaskGroup { group in
                group.addTask { try await self.fetchPages() }
                group.addTask { try await self.fetchAggregate() }
            }
        } catch {}
    }
}
