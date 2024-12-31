//
//  ProfileView.swift
//  UI
//
//  Created by Long Kim on 27/12/24.
//

import MidoriViewModels
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel

    @ObservedObject var model: ProfileViewModel

    var body: some View {
        Form {
            AccountSection(viewModel: accountViewModel)
            PersonalClientSection(viewModel: model)
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle(Text("Profile", bundle: .module))
    }
}

#Preview {
    @Previewable @StateObject var model = ProfileViewModel()

    ProfileView(model: model)
}
