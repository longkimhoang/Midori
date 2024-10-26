//
//  ChapterTests.swift
//  Storage
//
//  Created by Long Kim on 18/10/24.
//

import Dependencies
import Foundation
@testable import MidoriStorage
import SwiftData
import Testing

@Suite("Chapter model")
struct ChapterTests {
    @Dependency(\.modelContainer) var modelContainer

    @Test func savesSuccessfully() throws {
        let context = ModelContext(modelContainer)

        let chapterID = UUID()
        let mangaID = UUID()
        let scanlationGroupID = UUID()
        let chapterDate = Date()

        let manga = MangaEntity(id: mangaID, title: "title", createdAt: Date())
        context.insert(manga)

        let group = ScanlationGroupEntity(id: scanlationGroupID, name: "group")
        context.insert(group)

        let chapter = ChapterEntity(
            id: chapterID,
            volume: "1",
            title: "chapter",
            chapter: "1",
            readableAt: chapterDate
        )
        chapter.manga = manga
        chapter.scanlationGroup = group

        context.insert(chapter)

        #expect(throws: Never.self) {
            try context.save()
        }

        #expect(chapter.manga?.id == mangaID)
        #expect(chapter.scanlationGroup?.id == scanlationGroupID)
    }
}
