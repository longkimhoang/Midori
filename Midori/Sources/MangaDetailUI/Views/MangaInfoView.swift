//
//  MangaInfoView.swift
//
//
//  Created by Long Kim on 2/5/24.
//

import Algorithms
import Common
import MangaDetailCore
import NukeUI
import SwiftUI

struct MangaInfoView: View {
  @Environment(\.locale) private var locale
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let info: MangaFeed.MangaInfo

  var body: some View {
    let layout = if horizontalSizeClass == .compact {
      AnyLayout(VStackLayout(spacing: 24))
    } else {
      AnyLayout(HStackLayout(alignment: .top, spacing: 24))
    }

    layout {
      LazyImage(url: info.coverImageURL) { state in
        Rectangle()
          .fill(.fill.tertiary)
          .overlay {
            state.image?.resizable()
              .aspectRatio(contentMode: .fill)
          }
          .clipShape(.rect(cornerRadius: 16))
          .frame(width: 160, height: 160 / 0.7)
          .shadow(
            color: Color(white: 0, opacity: 0.2),
            radius: 12
          )
      }
      .pipeline(.default)

      HStack {
        VStack(alignment: horizontalSizeClass == .compact ? .center : .leading) {
          Text(info.title.localized(for: locale))
            .font(.title.weight(.medium))

          if !subtitle.isEmpty {
            Text(subtitle)
              .font(.title2)
              .foregroundStyle(.secondary)
          }

          if let description = info.description?.localized(for: locale) {
            Text(description)
              .lineLimit(4)
              .padding(.top, 2)
          }
        }

        if horizontalSizeClass == .regular {
          Spacer()
        }
      }
    }
  }

  private var subtitle: String {
    [info.authorName, info.artistName].compacted().formatted(.list(type: .and, width: .narrow))
  }
}
