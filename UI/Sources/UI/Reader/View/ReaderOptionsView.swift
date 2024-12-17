//
//  ReaderOptionsView.swift
//  UI
//
//  Created by Long Kim on 17/12/24.
//

import MidoriViewModels
import SwiftUI

struct ReaderOptionsView: View {
    @ObservedObject var model: ReaderOptionsViewModel

    var body: some View {
        VStack {
            Group {
                Toggle(String(localized: "Use right-to-left layout"), isOn: $model.useRightToLeftLayout)

                Divider()

                LabeledContent {
                    Picker(String(localized: "Page transition style"), selection: $model.transitionStyle) {
                        ForEach(ReaderOptionsViewModel.TransitionStyle.allCases, id: \.self) { style in
                            Text(style.label)
                        }
                    }
                } label: {
                    Text("Page transition style", bundle: .module)
                }
                .pickerStyle(.segmented)
                .labeledContentStyle(PageTransitionLabeledContentStyle())
            }
        }
        .padding()
        .frame(idealWidth: 300)
    }
}

private struct PageTransitionLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @StateObject var model = ReaderOptionsViewModel()

    ReaderOptionsView(model: model)
}
