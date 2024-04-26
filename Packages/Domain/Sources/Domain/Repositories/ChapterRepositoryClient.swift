//
//  ChapterRepositoryClient.swift
//
//
//  Created by Long Kim on 26/4/24.
//

import Dependencies
import DependenciesMacros
import Foundation
import Models
import Networking
import SwiftData

@DependencyClient
public struct ChapterRepositoryClient: Sendable {
  public var importChapters: @Sendable (_ chapters: [Networking.Chapter]) async throws -> Void
}

extension ChapterRepositoryClient: DependencyKey {
  public static var liveValue: ChapterRepositoryClient {
    @Dependency(\.modelContainer) var modelContainer
    let repository = ChapterRepository(modelContainer: modelContainer)

    return ChapterRepositoryClient(
      importChapters: { chapters in
        try await repository.importChapters(chapters)
      }
    )
  }

  public static let testValue = ChapterRepositoryClient()
}

public extension DependencyValues {
  var chapterRepository: ChapterRepositoryClient {
    get { self[ChapterRepositoryClient.self] }
    set { self[ChapterRepositoryClient.self] = newValue }
  }
}

// MARK: - Implementation

@ModelActor
actor ChapterRepository {
  typealias Chapter = Models.Chapter

  func importChapters(_ chapters: [Networking.Chapter]) throws {
    let models = chapters.map { chapter in
      Chapter(
        chapterID: chapter.id
      )
    }

    models.forEach { modelContext.insert($0) }
    try modelContext.save()
  }
}
