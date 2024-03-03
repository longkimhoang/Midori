//
//  PersistenceError.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Foundation

public enum PersistenceError: Error {
  case dataModelNotFound
  case initializationFailed(Error)
}
