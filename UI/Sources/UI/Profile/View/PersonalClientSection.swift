//
//  PersonalClientSection.swift
//  UI
//
//  Created by Long Kim on 28/12/24.
//

import MidoriViewModels
import SwiftUI

struct PersonalClientSection: View {
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            if viewModel.authState != .clientSetupRequired, !viewModel.personalClient.clientID.isEmpty {
                LabeledContent(
                    String(localized: "Client ID", bundle: .main),
                    value: viewModel.personalClient.clientID
                )
            }

            NavigationLink {
                PersonalClientInputForm(viewModel: viewModel)
            } label: {
                Text("Setup personal client", bundle: .module)
            }
        } header: {
            Text("Auth client", bundle: .module)
        } footer: {
            Text(
                """
                In order to access your account, you'll need to set up a personal OAuth client. \
                [Learn more](https://api.mangadex.org/docs/02-authentication/personal-clients/).
                """,
                bundle: .module
            )
        }
        .task {
            await viewModel.loadClientDetails()
        }
    }
}

private struct PersonalClientInputForm: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Form {
            Section {
                TextField(
                    String(localized: "Client ID", bundle: .module),
                    text: $viewModel.personalClient.clientID
                )

                SecureField(
                    String(localized: "Client secret", bundle: .module),
                    text: $viewModel.personalClient.clientSecret
                )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Setup personal client", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", bundle: .module)) {
                    Task {
                        await viewModel.savePersonalClient()
                        dismiss()
                    }
                }
            }
        }
    }
}
