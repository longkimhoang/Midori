//
//  ChapterStoreClient.swift
//
//
//  Created by Long Kim on 9/3/24.
//

import APIModels
import Database
import Dependencies
import DependenciesMacros
import Foundation
import SwiftData

@DependencyClient
public struct ChapterStoreClient {
  public var query: @MainActor (_ fetchDescriptor: FetchDescriptor<Database.Chapter>) throws
    -> [Database.Chapter]
  public var `import`: (_ chapters: [APIModels.Chapter]) async throws -> Void
}

extension ChapterStoreClient: DependencyKey {
  public static var liveValue: ChapterStoreClient {
    @Dependency(\.modelContainer) var modelContainer
    let store = ChapterStore(modelContainer: modelContainer)

    return ChapterStoreClient(
      query: { fetchDescriptor in
        try modelContainer.mainContext.fetch(fetchDescriptor)
      },
      import: { chapters in
        try await store.importChapters(chapters)
      }
    )
  }
}

extension ChapterStoreClient {
  @MainActor
  public func queryByIDs(
    _ ids: [UUID],
    modifyingDescriptorWith handler: (inout FetchDescriptor<Database.Chapter>) -> Void = { _ in }
  ) throws -> [Database.Chapter] {
    var fetchDescriptor = FetchDescriptor(
      predicate: #Predicate<Database.Chapter> { chapter in
        ids.contains(chapter.chapterID) && chapter.manga != nil
      }
    )
    handler(&fetchDescriptor)

    return try query(fetchDescriptor: fetchDescriptor)
  }
}

extension DependencyValues {
  public var chapterStore: ChapterStoreClient {
    get { self[ChapterStoreClient.self] }
    set { self[ChapterStoreClient.self] = newValue }
  }
}
