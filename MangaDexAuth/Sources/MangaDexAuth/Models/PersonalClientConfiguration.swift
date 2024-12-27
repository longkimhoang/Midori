//
//  PersonalClientConfiguration.swift
//  MangaDexAuth
//
//  Created by Long Kim on 27/12/24.
//

import Dependencies
import Foundation
import Security

public struct PersonalClientConfiguration: Sendable {
    public let clientID: String
    public let clientSecret: String

    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}
