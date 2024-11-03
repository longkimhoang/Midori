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
    let readableAt: Date

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline) {
                Text(title)
                    .font(.headline)
                    .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Spacer()

                Text(readableAt, format: .relative(presentation: .numeric))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ScanlationGroupLabel(group: group)
                .font(.subheadline)
        }
        .lineLimit(1)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MangaDetailChapterView(
        title: "Ch. 5 - A New Beginning",
        group: "A random group",
        readableAt: try! Date("2/11/24", strategy: .dateTime.day().month().year())
    )
    .padding()
}
