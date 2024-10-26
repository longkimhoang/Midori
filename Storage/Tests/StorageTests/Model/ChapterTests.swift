//
//  ChapterTests.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Dependencies
import Foundation
import GRDB
@testable import MidoriStorage
import Testing

@Suite struct ChapterTests {
    @Dependency(\.persistenceContainer) var persistenceContainer

    @Test func savesSuccessfully() throws {
        let chapterID = UUID()
        let mangaID = UUID()
        let scanlationGroupID = UUID()
        let chapterDate = Date()

        let chapter = try persistenceContainer.dbWriter.write { db in
            let group = ScanlationGroup(id: scanlationGroupID, name: "group")
            try group.save(db)

            let manga = MangaEntity(id: mangaID, title: "title", createdAt: Date())
            try manga.save(db)

            let chapter = Chapter(
                id: chapterID,
                mangaID: mangaID,
                scanlationGroupID: scanlationGroupID,
                volume: "1",
                title: "chapter",
                chapter: "1",
                readableAt: chapterDate
            )
            return try chapter.saveAndFetch(db)
        }

        #expect(chapter.id == chapterID)
        #expect(chapter.mangaID == mangaID)
        #expect(chapter.scanlationGroupID == scanlationGroupID)
        #expect(chapter.volume == "1")
        #expect(chapter.title == "chapter")
        #expect(chapter.chapter == "1")
        #expect(chapter.readableAt.timeIntervalSince1970
            .isApproximatelyEqual(to: chapterDate.timeIntervalSince1970))

        let manga = try persistenceContainer.dbWriter.read(chapter.manga.fetchOne)
        #expect(manga?.id == mangaID)

        let scanlationGroup = try persistenceContainer.dbWriter
            .read(chapter.scanlationGroup.fetchOne)
        #expect(scanlationGroup?.id == scanlationGroupID)
    }
}
