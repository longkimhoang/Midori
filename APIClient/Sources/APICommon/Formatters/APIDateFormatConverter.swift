//
//  APIDateFormatConverter.swift
//
//
//  Created by Long Kim on 26/02/2024.
//

import Foundation
import HelperCoders

package struct APIDateFormatConverter: DateFormatConverter {
  package func string(from date: Date) -> String {
    date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false))
  }

  package func date(from string: String) -> Date? {
    try? Date(string, strategy: .iso8601)
  }
}

package extension DateFormatConverter where Self == APIDateFormatConverter {
  package static var api: Self { APIDateFormatConverter() }
}
