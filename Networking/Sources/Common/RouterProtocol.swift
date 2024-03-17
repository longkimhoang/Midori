//
//  RouterProtocol.swift
//
//
//  Created by Long Kim on 06/03/2024.
//

import Alamofire
import Foundation

package protocol RouterProtocol: URLRequestConvertible {
  var baseURL: URL { get }
  var method: HTTPMethod { get }
  var path: String { get }

  func modifyRequest(_ request: inout URLRequest) throws
}

package extension RouterProtocol {
  var baseURL: URL {
    URL(string: "https://api.mangadex.org")!
  }

  var method: HTTPMethod { .get }

  func modifyRequest(_: inout URLRequest) throws {
    // Do nothing
  }

  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appending(path: path)
    var request = URLRequest(url: url)
    request.method = method

    try modifyRequest(&request)
    return request
  }
}
