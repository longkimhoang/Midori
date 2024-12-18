//
//  PageScrubberView.swift
//  UI
//
//  Created by Long Kim on 19/12/24.
//

import MidoriViewModels
import SwiftUI

struct PageScrubberView: View {
    @ObservedObject var viewModel: PageScrubberViewModel

    var body: some View {
        let range = 1 ... Double(viewModel.numberOfPages)

        Slider(value: value, in: range) {
            Text("Current page", bundle: .module)
        }
        .padding()
        .frame(idealWidth: 300)
        .sensoryFeedback(.selection, trigger: viewModel.currentPage)
        .accessibilityValue(viewModel.currentPage.formatted(.number))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value.wrappedValue < range.upperBound {
                    value.wrappedValue += 1
                }
            case .decrement:
                if value.wrappedValue > range.lowerBound {
                    value.wrappedValue -= 1
                }
            @unknown default:
                break
            }
        }
    }

    private var value: Binding<Double> {
        Binding(
            get: { Double(viewModel.currentPage) },
            set: { viewModel.currentPage = Int($0) }
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var viewModel = PageScrubberViewModel()

    PageScrubberView(viewModel: viewModel)
        .onAppear {
            viewModel.numberOfPages = 5
        }
}
