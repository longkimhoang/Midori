//
//  MangaFeed.swift
//
//
//  Created by Long Kim on 3/5/24.
//

import Alamofire
import Foundation

public struct MangaFeedRequest: URLRequestConvertible, Sendable {
  public enum Reference: String, Encodable, Sendable {
    case manga
    case scanlationGroup = "scanlation_group"
    case user
  }

  public struct Order: Encodable, Sendable {
    public let volume: SortOrder?
    public let chapter: SortOrder?

    public init(volume: SortOrder? = nil, chapter: SortOrder? = nil) {
      self.volume = volume
      self.chapter = chapter
    }
  }

  public struct Parameters: Encodable, Sendable {
    public let limit: Int
    public let offset: Int?
    public let includes: [Reference]

    public init(
      limit: Int = 100,
      offset: Int? = nil,
      includes: [Reference] = [.scanlationGroup]
    ) {
      self.limit = limit
      self.offset = offset
      self.includes = includes
    }
  }

  public let mangaID: UUID
  public let parameters: Parameters

  public init(mangaID: UUID, parameters: Parameters = .init()) {
    self.mangaID = mangaID
    self.parameters = parameters
  }

  public func asURLRequest() throws -> URLRequest {
    let id = mangaID.uuidString.lowercased()
    var request = URLRequest(url: Constants.baseURL.appending(path: "manga/\(id)/feed"))
    request = try URLEncodedFormParameterEncoder(encoder: .api).encode(parameters, into: request)

    return request
  }
}

public struct MangaFeedResponse: Decodable, Sendable {
  public let limit: Int
  public let offset: Int
  public let total: Int
  public let data: [Chapter]
}
