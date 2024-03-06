//
//  Router.swift
//
//
//  Created by Long Kim on 07/03/2024.
//

import Alamofire
import APICommon
import Foundation

enum Router: RouterProtocol {
  case listChapters(ListChapters.Parameters?)

  var path: String {
    switch self {
    case .listChapters: "chapter"
    }
  }

  func modifyRequest(_ request: inout URLRequest) throws {
    switch self {
    case let .listChapters(parameters):
      request = try URLEncodedFormParameterEncoder().encode(parameters, into: request)
    }
  }
}
