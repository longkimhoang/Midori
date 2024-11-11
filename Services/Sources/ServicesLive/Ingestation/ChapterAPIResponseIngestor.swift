//
//  ChapterAPIResponseIngestor.swift
//  Services
//
//  Created by Long Kim on 28/10/24.
//

import Foundation
import IdentifiedCollections
import MangaDexAPIClient
import MidoriStorage
import SwiftData

@ModelActor
actor ChapterAPIResponseIngestor {
    private var scanlationGroupIDs: [UUID: PersistentIdentifier] = [:]

    func importChapters(_ chaptersByManga: [PersistentIdentifier: [Chapter]]) throws {
        for (mangaID, chapters) in chaptersByManga {
            let mangaEntity = self[mangaID, as: MangaEntity.self]

            for chapter in chapters {
                let chapterEntity = ChapterEntity(
                    id: chapter.id,
                    volume: chapter.volume,
                    title: chapter.title,
                    chapter: chapter.chapter,
                    readableAt: chapter.readableAt
                )
                chapterEntity.manga = mangaEntity

                if let group = chapter.relationship(ScanlationGroupRelationship.self)?.referenced {
                    if let groupID = scanlationGroupIDs[group.id] {
                        chapterEntity.scanlationGroup =
                            self[groupID, as: ScanlationGroupEntity.self]
                    } else {
                        let groupEntity = ScanlationGroupEntity(
                            id: group.id,
                            name: group.name,
                            groupDescription: group.description
                        )
                        chapterEntity.scanlationGroup = groupEntity
                        scanlationGroupIDs[group.id] = groupEntity.persistentModelID
                    }
                }

                modelContext.insert(chapterEntity)
            }
        }

        try modelContext.save()
    }

    func importPages(from response: AtHomeServer, for chapterID: UUID) throws {
        guard let chapter = try modelContext.fetch(ChapterEntity.withID(chapterID)).first else {
            return
        }

        let baseURL = response.baseURL
        let hash = response.chapter.hash

        for (index, fileName) in response.chapter.data.enumerated() {
            let imageURL = baseURL.appending(components: "data", hash, fileName)
            let pageEntity = PageEntity(
                pageIndex: index,
                quality: .normal,
                imageURL: imageURL
            )
            pageEntity.chapter = chapter
            modelContext.insert(pageEntity)
        }

        for (index, fileName) in response.chapter.dataSaver.enumerated() {
            let imageURL = baseURL.appending(components: "data-saver", hash, fileName)
            let pageEntity = PageEntity(
                pageIndex: index,
                quality: .dataSaver,
                imageURL: imageURL
            )
            pageEntity.chapter = chapter
            modelContext.insert(pageEntity)
        }

        try modelContext.save()
    }
}
