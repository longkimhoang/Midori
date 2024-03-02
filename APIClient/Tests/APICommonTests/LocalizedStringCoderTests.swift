//
//  LocalizedStringCoderTests.swift
//
//
//  Created by Long Kim on 28/02/2024.
//

import MetaCodable
import XCTest

@testable import APICommon

final class LocalizedStringCoderTests: XCTestCase {
  @Codable
  struct TestData {
    @CodedBy(LocalizedStringCoder())
    let string: LocalizedString
  }

  func testDecode() throws {
    let json = """
    {
      "string": {
        "vi": "A localized string"
      }
    }
    """.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(TestData.self, from: json)
    let string = try XCTUnwrap(decoded.string)
    XCTAssertEqual(string.languageCode, "vi")
    XCTAssertEqual(string.value, "A localized string")
  }

  func testDecodeError() {
    let json = """
    {
      "string": {}
    }
    """.data(using: .utf8)!

    XCTAssertThrowsError(try JSONDecoder().decode(TestData.self, from: json))
  }

  func testInitializeFromString() {
    let localized: LocalizedString = "A localized string"
    XCTAssertEqual(localized.languageCode, "en")
    XCTAssertEqual(localized.value, "A localized string")
  }
}
