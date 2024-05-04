//
//  GetManga.swift
//
//
//  Created by Long Kim on 4/5/24.
//

import Alamofire
import Foundation

public struct GetMangaRequest: URLRequestConvertible, Sendable {
  public enum Reference: String, Encodable, Sendable {
    case manga
    case cover = "cover_art"
    case author
    case artist
  }

  public struct Parameters: Encodable, Sendable {
    public let includes: [Reference]

    public init(includes: [Reference] = [.cover, .author, .artist]) {
      self.includes = includes
    }
  }

  public let id: UUID
  public let parameters: Parameters

  public init(id: UUID, parameters: Parameters = .init()) {
    self.id = id
    self.parameters = parameters
  }

  public func asURLRequest() throws -> URLRequest {
    let url = Constants.baseURL.appending(path: "manga/\(id.uuidString.lowercased())")
    var request = URLRequest(url: url)
    request = try URLEncodedFormParameterEncoder(encoder: .api).encode(parameters, into: request)

    return request
  }
}

public struct GetMangaResponse: Decodable {
  public let data: Manga
}
