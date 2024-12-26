//
//  AuthError.swift
//  MangaDexAuth
//
//  Created by Long Kim on 27/12/24.
//

import Foundation

public enum AuthError: Error {
    case invalidConfiguration
    case network(URLResponse)
    case missingCredential
}
