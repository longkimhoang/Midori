//
//  LocalizedString+Initializers.swift
//
//
//  Created by Long Kim on 24/4/24.
//

import Networking
import NonEmpty

extension LocalizedString {
  init(_ apiModel: Networking.LocalizedString) {
    self.init(values: apiModel.values)
  }
}
