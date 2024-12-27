//
//  ProfileViewModel.swift
//  ViewModels
//
//  Created by Long Kim on 27/12/24.
//

import Foundation

@MainActor
public final class ProfileViewModel: ObservableObject {
    public var account = AccountViewModel()

    public init() {}
}
