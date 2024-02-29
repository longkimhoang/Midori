//
//  Router.swift
//
//
//  Created by Long Kim on 28/02/2024.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
  case listMangas(ListMangas.Parameters?)

  var baseURL: URL {
    URL(string: "https://api.mangadex.org")!
  }

  var method: HTTPMethod {
    switch self {
    case .listMangas: .get
    }
  }

  var path: String {
    switch self {
    case .listMangas: "manga"
    }
  }

  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appending(path: path)
    var request = URLRequest(url: url)
    request.method = method

    switch self {
    case .listMangas(let parameters):
      let defaultParameters = [
        "includes": ["cover_art", "artist"]
      ]
      request = try URLEncodedFormParameterEncoder.default.encode(parameters, into: request)
      request = try URLEncodedFormParameterEncoder.default.encode(defaultParameters, into: request)
    }

    return request
  }
}
