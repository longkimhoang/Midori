//
//  ChapterEntity+Extensions.swift
//  Features
//
//  Created by Long Kim on 2/11/24.
//

import MidoriStorage

extension ChapterEntity {
    /// A title combining volume, chapter number, and chapter title.
    var combinedTitle: String {
        let localizedChapter = chapter.map {
            String(localized: "Ch. \($0)", bundle: .module, comment: "Shortform for chapter")
        }

        let localizedVolume = volume.map {
            String(localized: "Vol. \($0)", bundle: .module, comment: "Shortform for volume")
        }

        let name = [localizedVolume, localizedChapter, title].compacted()
            .joined(separator: " - ")

        return name.isEmpty ? String(localized: "Oneshot", bundle: .module) : name
    }

    /// The name of the group that scanlated the chapter, or a generic name if the group is unknown.
    var groupName: String {
        scanlationGroup?.name ?? String(localized: "No group", bundle: .module)
    }
}
