//
//  PopularMangaView.swift
//
//
//  Created by Long Kim on 03/03/2024.
//

import Foundation
import SwiftUI

struct PopularMangaView: View {
  let id: UUID

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Color.secondary
        .aspectRatio(1 / 1.42, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 8))

      VStack(alignment: .leading) {
        Text(id.uuidString)
          .font(.title3)
          .lineLimit(4)

        Text("Artist name here")
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
  }
}
