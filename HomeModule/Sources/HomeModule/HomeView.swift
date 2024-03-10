//
//  HomeView.swift
//
//
//  Created by Long Kim on 02/03/2024.
//

import ConcurrencyExtras
import Dependencies
import Foundation
import SwiftUI

public struct HomeView: View {
  @State private var model = HomeViewModel()

  public init() {}

  public var body: some View {
    NavigationStack {
      HomeCollectionView(model: model)
      #if os(iOS)
        .ignoresSafeArea()
      #endif
        .navigationTitle("Home")
        .refreshable {
          await model.fetchHomeData().cancellableValue
        }
//        .overlay {
//          switch model.fetchStatus {
//          case .loading:
//            ContentUnavailableView {
//              ProgressView()
//                .controlSize(.large)
//            } description: {
//              Text("Loading...")
//            }
//          case let .failure(error):
//            ContentUnavailableView {
//              Text(error.localizedDescription)
//            } actions: {
//              Button("Retry") {
//                model.fetchHomeData()
//              }
//            }
//          default:
//            EmptyView()
//          }
//        }
    }
    .task {
      await model.fetchHomeData().cancellableValue
    }
  }
}
