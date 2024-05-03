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

  let manga: Manga

  var body: some View {
    let layout = if horizontalSizeClass == .compact {
      AnyLayout(VStackLayout(spacing: 24))
    } else {
      AnyLayout(HStackLayout(alignment: .top, spacing: 24))
    }

    layout {
      LazyImage(url: manga.coverImageURL) { state in
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
          let title = manga.title.localized(for: locale)

          Text(title)
            .font(.title.weight(.medium))

          if !subtitle.isEmpty {
            Text(subtitle)
              .font(.title2)
              .foregroundStyle(.secondary)
          }

          if let description = manga.description?.localized(for: locale) {
            ExpandableDescription(
              title: title,
              description: description
            )
            .padding(.top, 2)
          }
        }
        .multilineTextAlignment(horizontalSizeClass == .compact ? .center : .leading)

        if horizontalSizeClass == .regular {
          Spacer()
        }
      }
    }
  }

  private var subtitle: String {
    [manga.authorName, manga.artistName].compacted().formatted(.list(type: .and, width: .narrow))
  }
}

private struct ExpandableDescription: View {
  @State private var showsReadMoreButton: Bool = false
  @State private var showsExpandedDescription: Bool = false

  let title: String
  let description: String

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(description)
          .multilineTextAlignment(.leading)
          .lineLimit(4)
          .foregroundStyle(.secondary)
          .background {
            GeometryReader { geometry in
              Color.clear
                .onAppear {
                  let font = UIFont.preferredFont(forTextStyle: .body)
                  let rect = description.boundingRect(
                    with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: [.font: font],
                    context: nil
                  )

                  showsReadMoreButton = rect.height > geometry.size.height
                }
            }
          }

        if showsReadMoreButton {
          Button {
            showsExpandedDescription = true
          } label: {
            Text("read more", bundle: .module)
          }
          .buttonStyle(.borderless)
          .font(.subheadline.smallCaps())
        }
      }

      Spacer()
    }
    .font(.subheadline)
    .sheet(isPresented: $showsExpandedDescription) {
      NavigationStack {
        ScrollView {
          HStack {
            Text(description)
              .multilineTextAlignment(.leading)

            Spacer()
          }
          .scenePadding(.minimum, edges: .horizontal)
        }
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button {
              showsExpandedDescription = false
            } label: {
              Text("Close", bundle: .module)
            }
          }
        }
      }
    }
  }
}
