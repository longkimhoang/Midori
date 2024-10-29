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

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)

                authorsText

                Spacer()
            }
            .lineLimit(2)

            Spacer()
        }
    }

    @ViewBuilder private var authorsText: some View {
        if let authors {
            Text(authors)
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PopularMangaView(
        title: """
        Taida na Akujoku Kizoku ni Tensei shita Ore, Scenario o \
        Bukkowashitara Kikakugai no Maryoku de Saikyou ni Natta
        """,
        authors: "Kikuchi Kousei, Odadouma"
    )
    .padding()
}
