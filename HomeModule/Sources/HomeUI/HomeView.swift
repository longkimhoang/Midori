//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import Foundation
import HomeUseCases
import SwiftUI

public struct HomeView: View {
  public init() {}

  public var body: some View {
    EmptyView()
      .task {
        do {
          let homeData = try await RetrieveHomeDataUseCase().execute()
        } catch {}
      }
  }
}
