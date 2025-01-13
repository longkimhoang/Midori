//
//  UpdatesViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 2/1/25.
//

import Dependencies
import Foundation
import IdentifiedCollections
import MidoriServices
import MidoriStorage
import OrderedCollections

@MainActor
public final class UpdatesViewModel: ObservableObject {
    @Dependency(\.modelContainer) private var modelContainer
    @Dependency(\.mangaService) private var mangaService: MangaService

    private var offset: Int = 0

    @Published public var sections: IdentifiedArrayOf<Section> = []

    public init() {}

    public func loadFollowedFeedFromStorage() throws {
        let context = modelContainer.mainContext
        let chapterEntities = try context.fetch(ChapterEntity.followedFeed(limit: 32))
        let chaptersGroupedByMangaID: OrderedDictionary<UUID, [ChapterEntity]> =
            chapterEntities.reduce(into: [:]) { result, chapterEntity in
                guard let manga = chapterEntity.manga else {
                    return
                }
                result[manga.id, default: []].append(chapterEntity)
            }

        let sections: [Section] = chaptersGroupedByMangaID.values.compactMap { chapterEntities in
            guard let chapterEntity = chapterEntities.first, let mangaEntity = chapterEntity.manga else {
                return nil
            }

            let manga = Section.MangaInfo(
                id: mangaEntity.id,
                title: mangaEntity.title,
                coverImageURL: mangaEntity.currentCover?.imageURLs[.mediumThumbnail]
            )
            let chapters = chapterEntities.map(Chapter.init)
            return Section(mangaInfo: manga, chapters: IdentifiedArray(uniqueElements: chapters))
        }

        offset = chapterEntities.count
        self.sections = IdentifiedArray(uniqueElements: sections)
    }

    public func fetchFollowedFeed() async throws {
        try await mangaService.syncUserFollowedFeed(limit: 32, offset: offset)
        try loadFollowedFeedFromStorage()
    }
}
