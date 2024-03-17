//
//  ContentUnavailableView+Initializers.swift
//
//
//  Created by Long Kim on 17/3/24.
//

import SwiftUI

public extension ContentUnavailableView where Label == LoadingUnavailableContent.Label,
  Description == LoadingUnavailableContent.Description, Actions == EmptyView
{
  static var loading: Self {
    ContentUnavailableView {
      LoadingUnavailableContent.Label()
    } description: {
      LoadingUnavailableContent.Description()
    }
  }
}

public enum LoadingUnavailableContent {
  public struct Label: View {
    public var body: some View {
      ProgressView()
        .controlSize(.large)
    }
  }

  public struct Description: View {
    public var body: some View {
      Text("Loading...", bundle: .module)
    }
  }
}
