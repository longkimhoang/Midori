//
//  AccountSection.swift
//  UI
//
//  Created by Long Kim on 28/12/24.
//

import MidoriViewModels
import SwiftUI

struct AccountSection: View {
    private enum Field {
        case username
        case password
    }

    @State private var username: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?

    @ObservedObject var viewModel: AccountViewModel

    var body: some View {
        Section {
            switch viewModel.authState {
            case .loggedOut:
                TextField(String(localized: "Username", bundle: .module), text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .username)
                    .submitLabel(.continue)
                    .onSubmit {
                        focusedField = .password
                    }

                SecureField(String(localized: "Password", bundle: .module), text: $password)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.done)
                    .onSubmit {
                        handleSubmit()
                    }

                Button(String(localized: "Sign in", bundle: .module)) {
                    focusedField = nil
                    handleSubmit()
                }
            case .loggedIn:
                EmptyView()
            case .clientSetupRequired:
                Text("Client setup required", bundle: .module)
                    .foregroundStyle(.secondary)
            case nil:
                ProgressView()
            }
        } header: {
            Text("Account", bundle: .module)
        }
    }

    private func handleSubmit() {
        guard !username.isEmpty, !password.isEmpty else {
            return
        }

        Task {
            try await viewModel.signIn(username: username, password: password)
        }
    }
}
