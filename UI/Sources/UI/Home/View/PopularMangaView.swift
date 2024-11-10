//
//  PopularMangaView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import SwiftUI

struct PopularMangaView: View {
    let title: String
    let authors: String?
    let coverImage: Image?

    var body: some View {
        HStack(alignment: .top) {
            CoverImageView(image: coverImage)
                .background(
                    .background.shadow(.drop(color: Color(white: 0, opacity: 0.15), radius: 8, y: 12)),
                    in: .rect(cornerRadius: 8)
                )

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                if let authors {
                    Text(authors)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }
}
