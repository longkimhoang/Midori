//
//  Home.swift
//  Features
//
//  Created by Long Kim on 27/10/24.
//

import ComposableArchitecture

@Reducer
public struct Home {
    @ObservableState
    public struct State: Equatable {
        public var popularMangas: IdentifiedArrayOf<PopularManga>

        public init(popularMangas: IdentifiedArrayOf<PopularManga> = []) {
            self.popularMangas = popularMangas
        }
    }
}
