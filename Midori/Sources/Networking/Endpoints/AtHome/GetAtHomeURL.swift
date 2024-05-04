//
//  GetAtHomeURL.swift
//
//
//  Created by Long Kim on 4/5/24.
//

import Alamofire
import Foundation

public struct GetAtHomeURLRequest: URLRequestConvertible, Sendable {
  public struct Parameters: Encodable, Sendable {
    public let forcePort443: Bool

    public init(forcePort443: Bool = false) {
      self.forcePort443 = forcePort443
    }
  }

  public let chapterID: UUID
  public let parameters: Parameters

  public init(chapterID: UUID, parameters: Parameters = .init()) {
    self.chapterID = chapterID
    self.parameters = parameters
  }

  public func asURLRequest() throws -> URLRequest {
    let url = Constants.baseURL
      .appending(path: "at-home/server/\(chapterID.uuidString.lowercased())")
    var request = URLRequest(url: url)
    request = try URLEncodedFormParameterEncoder(encoder: .api).encode(parameters, into: request)

    return request
  }
}

public struct GetAtHomeURLResponse: Decodable, Sendable {
  public struct Chapter: Decodable, Sendable {
    public let hash: String
    public let data: [String]
    public let dataSaver: [String]
  }

  public let baseURL: URL
  public let chapter: Chapter

  public enum CodingKeys: String, CodingKey {
    case baseURL = "baseUrl"
    case chapter
  }
}
