//
//  ProfileView.swift
//  UI
//
//  Created by Long Kim on 27/12/24.
//

import MidoriViewModels
import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: ProfileViewModel

    var body: some View {
        Form {
            PersonalClientSection(viewModel: model.account)
        }
        .navigationTitle(Text("Profile", bundle: .module))
    }
}

private struct PersonalClientSection: View {
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            if viewModel.authState != .clientSetupRequired {}

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
                [Learn more](https://api.mangadex.org/docs/02-authentication/personal-clients/)
                """,
                bundle: .module
            )
        }
        .task {
            await viewModel.loadClientFromKeychain()
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
                    text: $viewModel.personalClientInput.clientID
                )

                SecureField(
                    String(localized: "Client secret", bundle: .module),
                    text: $viewModel.personalClientInput.clientSecret
                )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Setup personal client", bundle: .module))
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", bundle: .module)) {
                    viewModel.setupPersonalClient()
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var model = ProfileViewModel()

    ProfileView(model: model)
}
