//
//  AccountViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Combine
import Foundation

@MainActor
public final class AccountViewModel: ObservableObject {
    @Published public var authState: AuthState?
    @Published public var personalClientInput = PersonalClientInput()

    public init() {}

    public func setupPersonalClient() {}

    public nonisolated func loadClientFromKeychain() async {}
}
