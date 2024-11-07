//
//  MangaDetailChapterView.swift
//  UI
//
//  Created by Long Kim on 3/11/24.
//

import SwiftUI

struct MangaDetailChapterView: View {
    let title: String
    let group: String
    let readableAt: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline) {
                Text(title)
                    .font(.headline)
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Spacer()

                Text(readableAt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScanlationGroupLabel(group: group)
                .font(.subheadline)
        }
        .lineLimit(1)
    }
}
