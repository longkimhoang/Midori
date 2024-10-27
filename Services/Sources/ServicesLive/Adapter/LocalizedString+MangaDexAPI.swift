//
//  LocalizedString+MangaDexAPI.swift
//  Services
//
//  Created by Long Kim on 27/10/24.
//

import MangaDexAPIClient
import MidoriStorage
import NonEmpty

extension MidoriStorage.LocalizedString {
    init(_ apiString: MangaDexAPIClient.LocalizedString) {
        let defaultVariant = apiString.defaultVariant
        let localizedVariants: [LanguageCode: String] = apiString.localizedVariants
            .reduce(into: [:]) { result, element in
                result[LanguageCode(element.key)] = element.value
            }

        self.init(localizedVariants: NonEmpty(
            (LanguageCode(defaultVariant.0), defaultVariant.1),
            localizedVariants
        ))
    }
}
