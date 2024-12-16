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

@MainActor public final class ReaderViewModel {
    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.chapterService) private var chapterService
    @Dependency(\.mangaService) private var mangaService

    @Published public var chapterID: UUID
    @Published public var chapter: Chapter?
    @Published public var pages: IdentifiedArrayOf<Page> = []
    @Published public var aggregate: Aggregate?
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

        for (volumeIndex, volume) in aggregate.volumes.indexed() {
            guard var chapterIndex = volume.chapters.index(id: chapterID) else {
                continue
            }

            // if chapter is the first of a volume, return the last chapter
            // of the next volume if available
            guard chapterIndex > volume.chapters.startIndex else {
                // if there's no next volume, return nil
                if volumeIndex == aggregate.volumes.startIndex {
                    return nil
                } else {
                    let index = aggregate.volumes.index(before: volumeIndex)
                    return aggregate.volumes[index].chapters.last
                }
            }

            volume.chapters.formIndex(before: &chapterIndex)
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
