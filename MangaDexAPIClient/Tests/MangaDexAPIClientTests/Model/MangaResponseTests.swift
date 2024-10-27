//
//  MangaResponseTests.swift
//  MangaDexAPIClient
//
//  Created by Long Kim on 21/10/24.
//

import Foundation
@testable import MangaDexAPIClient
import MangaDexAPIStubs
import Testing

@Suite("Manga endpoint responses")
struct MangaResponseTests {
    let decoder = JSONDecoder.mangaDexAPI

    @Test("Get manga list")
    func decodesGetMangaListResponse() throws {
        let response = try decoder.decode(
            GetMangaListResponse.self,
            from: MangaDexAPIStubs.Manga.List.success
        )

        #expect(response.limit == 10)
        #expect(response.offset == 0)

        let data = response.data
        #expect(data.count == 10)

        let manga = try #require(data.first)

        #expect(manga.id == UUID(uuidString: "b0dc2f88-4e89-4e30-8d68-20116db788ff"))
        #expect(manga.title.defaultVariant.1 == """
        Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o Bukkowashitara Kikakugai no \
        Maryoku de Saikyou ni Natta
        """)
        #expect(manga.title.localizedVariants.isEmpty)

        let relationships = manga.relationships
        #expect(relationships.count == 3)

        let author = try #require(manga.relationship(AuthorRelationship.self))
        #expect(author.id == UUID(uuidString: "1556896e-ac71-4fe0-9a97-e40cc7f3b29e"))

        let authorAttributes = try #require(author.attributes)
        #expect(authorAttributes.name == "Kikuchi Kousei")
    }
}
