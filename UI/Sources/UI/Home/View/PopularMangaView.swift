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
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    .fill.secondary.shadow(.drop(radius: 8, y: 12))
                )
                .overlay {
                    if let coverImage {
                        coverImage
                            .resizable()
                            .aspectRatio(0.7, contentMode: .fill)
                            .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .aspectRatio(0.7, contentMode: .fit)

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
        .opacity(isHighlighted ? 0.5 : 1)
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
