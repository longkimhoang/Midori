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

    func importChapters(_ chaptersByManga: [UUID: [Chapter]]) throws {
        let mangaIDs = Set(chaptersByManga.keys)
        let mangasByID = FetchDescriptor(
            predicate: #Predicate<MangaEntity> { mangaIDs.contains($0.id) }
        )
        let mangas = try IdentifiedArray(uniqueElements: modelContext.fetch(mangasByID))

        for (mangaID, chapters) in chaptersByManga {
            let mangaEntity = mangas[id: mangaID]

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
}
