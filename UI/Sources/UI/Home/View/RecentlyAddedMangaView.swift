//
//  RecentlyAddedMangaView.swift
//  UI
//
//  Created by Long Kim on 31/10/24.
//

import SwiftUI

struct RecentlyAddedMangaView: View {
    @Environment(\.displayScale) private var displayScale

    let title: String
    let coverImage: Image?

    var body: some View {
        VStack(alignment: .leading) {
            CoverImageView(image: coverImage)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.separator, lineWidth: 1 / displayScale)
                }

            Text(title)
                .font(.headline)
                .lineLimit(2)
        }
    }
}
