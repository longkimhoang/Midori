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
            AccountSection(viewModel: model.account)
            PersonalClientSection(viewModel: model.account)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Profile", bundle: .module))
    }
}

private struct AccountSection: View {
    private enum Field {
        case username
        case password
    }

    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?

    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        switch viewModel.authState {
        case .loggedOut:
            section {
                TextField(String(localized: "Username", bundle: .module), text: $username)
                    .textContentType(.username)
                    .focused($focusedField, equals: .username)

                SecureField(String(localized: "Password", bundle: .module), text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)

                Button(String(localized: "Sign in", bundle: .module)) {
                    focusedField = nil
                }
            }
            .onSubmit {
                print("Submit")
            }
        case .loggedIn:
            EmptyView()
        case nil, .clientSetupRequired:
            EmptyView()
        }
    }

    private func section<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        Section {
            content()
        } header: {
            Text("Account", bundle: .module)
        }
    }
}

private struct PersonalClientSection: View {
    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            if viewModel.authState != .clientSetupRequired, !viewModel.personalClientInput.clientID.isEmpty {
                LabeledContent(
                    String(localized: "Client ID", bundle: .main),
                    value: viewModel.personalClientInput.clientID
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
                    Task {
                        await viewModel.savePersonalClient()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var model = ProfileViewModel()

    ProfileView(model: model)
}
