//
//  AppView.swift
//  Midori
//
//  Created by Long Kim on 26/02/2024.
//

import SwiftUI

struct AppView: View {
  var body: some View {
    #if os(iOS)
    AppTabView()
    #else
    AppSplitView()
    #endif
  }
}
