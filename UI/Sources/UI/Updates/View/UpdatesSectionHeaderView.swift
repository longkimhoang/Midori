//
//  UpdatesSectionHeaderView.swift
//  UI
//
//  Created by Long Kim on 13/1/25.
//

import SwiftUI

struct UpdatesSectionHeaderContentView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title)
            .textScale(.secondary)
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .frame(height: 120, alignment: .bottomLeading)
            .lineLimit(2)
    }
}

struct UpdatesSectionHeaderBackgroundView: View {
    let coverImage: Image?

    var body: some View {
        Rectangle()
            .fill(.fill.tertiary)
            .overlay {
                GeometryReader { geometry in
                    coverImage?
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 2, opaque: true)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            }
            .overlay(
                .linearGradient(colors: [.black.opacity(0.8), .black.opacity(0.2)], startPoint: .bottom, endPoint: .top)
            )
    }
}
