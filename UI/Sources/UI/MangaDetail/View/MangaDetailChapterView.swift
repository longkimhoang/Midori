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

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.medium)

            ScanlationGroupLabel(group: group)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MangaDetailChapterView(
        title: "Ch. 5 - A New Beginning",
        group: "A random group"
    )
    .padding()
}
