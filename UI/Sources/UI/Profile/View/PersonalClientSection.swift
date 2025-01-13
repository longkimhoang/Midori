//
//  PersonalClientSection.swift
//  UI
//
//  Created by Long Kim on 28/12/24.
//

import MidoriViewModels
import SwiftUI

struct PersonalClientSection: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        Section {
            if !viewModel.client.clientID.isEmpty {
                LabeledContent(String(localized: "Client ID", bundle: .main)) {
                    Text(viewModel.client.clientID)
                        .fontDesign(.monospaced)
                }
            }

            NavigationLink {
                PersonalClientInputForm(viewModel: viewModel)
                    .environmentObject(accountViewModel)
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
    }
}

private struct PersonalClientInputForm: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        Form {
            Section {
                TextField(
                    String(localized: "Client ID", bundle: .module),
                    text: $viewModel.client.clientID
                )
                .fontDesign(.monospaced)

                SecureField(
                    String(localized: "Client secret", bundle: .module),
                    text: $viewModel.client.clientSecret
                )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Setup personal client", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", bundle: .module)) {
                    Task {
                        await accountViewModel.savePersonalClient(viewModel.client)
                        dismiss()
                    }
                }
            }
        }
    }
}
