//
//  PopularMangaView.swift
//  UI
//
//  Created by Long Kim on 29/10/24.
//

import SwiftUI

struct PopularMangaConfiguration: Equatable {
    let title: String
    let authors: String?
    var isHighlighted: Bool = false
    var coverImage: UIImage?
}

struct PopularMangaView: View {
    let title: String
    let authors: String?
    var isHighlighted: Bool = false
    let coverImage: Image?

    var body: some View {
        HStack {
            CoverImageView(image: coverImage)
                .background(
                    .shadow(.drop(color: Color(white: 0, opacity: 0.15), radius: 8, y: 12)),
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

                Spacer()
            }
            .lineLimit(2)

            Spacer(minLength: 0)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PopularMangaView(
        title: """
        Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o \
        Bukkowashitara Kikakugai no Maryoku de Saikyou ni Natta
        """,
        authors: "Kikuchi Kousei, Odadouma",
        coverImage: Image(.mangaCoverPreview)
    )
    .frame(width: .infinity, height: 180)
    .background(.pink)
}
