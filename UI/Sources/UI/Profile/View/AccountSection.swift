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
            case let .loggedIn(user):
                AccountInformation(username: user.username)

                Button(String(localized: "Sign out", bundle: .module), role: .destructive) {
                    // sign out
                }
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

private struct AccountInformation: View {
    let username: String

    var body: some View {
        HStack {
            Circle()
                .foregroundStyle(.fill.tertiary)
                .overlay {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 48, height: 48)

            VStack(alignment: .leading) {
                Text(username)
                    .font(.title3)
                Text("Member", bundle: .module)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Logged in as \(username)", bundle: .module))
    }
}

#Preview("AccountInformation", traits: .sizeThatFitsLayout) {
    AccountInformation(username: "longkh158")
        .padding()
        .frame(maxWidth: .infinity)
}
