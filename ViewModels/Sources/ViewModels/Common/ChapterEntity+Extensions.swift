//
//  ChapterEntity+Extensions.swift
//  Features
//
//  Created by Long Kim on 2/11/24.
//

import MidoriStorage

extension ChapterEntity {
    /// A title combining volume, chapter number, and chapter title.
    func combinedTitle(includingVolume isVolumeIncluded: Bool = true) -> String {
        var components: [String] = []

        if let volume, isVolumeIncluded {
            let localizedVolume = String(localized: "Vol. \(volume)", bundle: .module, comment: "Shortform for volume")
            components.append(localizedVolume)
        }

        if let chapter {
            let localizedChapter = String(
                localized: "Ch. \(chapter)",
                bundle: .module,
                comment: "Shortform for chapter"
            )
            components.append(localizedChapter)
        }

        if let title {
            components.append(title)
        }

        let name = components.joined(separator: " - ")
        return name.isEmpty ? String(localized: "Oneshot", bundle: .module) : name
    }
}
