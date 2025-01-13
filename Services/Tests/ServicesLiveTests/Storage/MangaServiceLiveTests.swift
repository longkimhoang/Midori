//
//  MangaServiceLiveTests.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import Dependencies
import Foundation
import Get
import MangaDexAPIClient
import MangaDexAPIStubs
import MidoriServices
import MidoriServicesLive
import MidoriStorage
import Mocker
import SwiftData
import Testing

@Suite("Manga service")
final class MangaServiceLiveTests {
    @Dependency(\.modelContainer) var modelContainer

    let client: APIClient
    let service: MangaService

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let client = APIClient.mangaDex(sessionConfiguration: configuration)

        self.client = client
        service = withDependencies {
            $0.mangaDexAPIClient = client
        } operation: {
            MangaService.liveValue
        }
    }

    deinit {
        Mocker.removeAll()
    }

    @Test("Sync popular mangas")
    func syncPopularMangas() async throws {
        try await confirmation("Requested popular mangas") { requested in
            let request = MangaDexAPI.Manga.list(
                pagination: .init(limit: 10),
                order: [.followedCount: .descending],
                createdAtSince: Date(timeIntervalSinceReferenceDate: -2_668_400)
            )

            var mock = try await Mock(
                request: client.makeURLRequest(for: request),
                statusCode: 200,
                data: MangaDexAPIStubs.Manga.List.success
            )
            mock.completion = {
                requested()
            }
            mock.register()

            try await withDependencies {
                $0.calendar = Calendar(identifier: .gregorian)
                $0.date = .constant(Date(timeIntervalSinceReferenceDate: 10000))
            } operation: {
                try await service.syncPopularMangas()
            }

            let context = ModelContext(modelContainer)
            let mangas = try context.fetch(FetchDescriptor<MangaEntity>())

            #expect(mangas.count == 10)

            let mangaID = UUID(uuidString: "b0dc2f88-4e89-4e30-8d68-20116db788ff")
            let manga = try #require(mangas.first { $0.id == mangaID })
            #expect(
                manga.title == """
                Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o Bukkowashitara Kikakugai no \
                Maryoku de Saikyou ni Natta
                """
            )

            let author = try #require(manga.author)
            #expect(author.name == "Kikuchi Kousei")

            let artist = try #require(manga.artist)
            #expect(artist.name == "Odadouma")
        }
    }
}
