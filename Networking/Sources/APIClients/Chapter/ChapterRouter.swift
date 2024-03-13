//
//  ChapterRouter.swift
//
//
//  Created by Long Kim on 13/3/24.
//

import Alamofire
import Common
import Foundation

enum ChapterRouter: RouterProtocol {
  case listChapters(ListChaptersParameters?)

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
