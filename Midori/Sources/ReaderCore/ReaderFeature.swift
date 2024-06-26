//
//  ReaderFeature.swift
//
//
//  Created by Long Kim on 11/5/24.
//

import Algorithms
import ComposableArchitecture
import Foundation
import Networking

@Reducer
public struct ReaderFeature: Sendable {
  @ObservableState
  public struct State: Equatable, Sendable {
    public var chapterID: UUID
    public var displayMode: DisplayMode = .singlePage
    public var pages: [Page] = []

    public init(chapterID: UUID) {
      self.chapterID = chapterID
    }
  }

  public enum Action: Sendable {
    case fetchPageURLs
    case chapterResponse(Result<Chapter, Error>)
  }

  @Dependency(\.atHomeAPI) private var atHomeAPI

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .fetchPageURLs:
        let chapterID = state.chapterID
        return .run { send in
          let response = try await atHomeAPI.getURL(request: .init(chapterID: chapterID))
          let baseURL = response.baseURL
          let hash = response.chapter.hash

          let pages: [Page] = response.chapter.data.indexed().map { index, path in
            Page(
              chapterID: chapterID,
              pageNumber: index,
              url: baseURL.appending(components: "data", hash, path)
            )
          }

          let dataSaverPages: [Page] = response.chapter.dataSaver.indexed().map { index, path in
            Page(
              chapterID: chapterID,
              pageNumber: index,
              url: baseURL.appending(components: "data-saver", hash, path)
            )
          }

          let chapter = Chapter(pages: pages, dataSaverPages: dataSaverPages)
          await send(.chapterResponse(.success(chapter)))
        } catch: { error, send in
          await send(.chapterResponse(.failure(error)))
        }
      case let .chapterResponse(.success(chapter)):
        state.pages = chapter.pages
        return .none
      case .chapterResponse(.failure):
        return .none
      }
    }
  }
}
