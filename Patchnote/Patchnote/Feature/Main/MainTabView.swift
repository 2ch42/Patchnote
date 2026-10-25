//
//  MainTabView.swift
//  Patchnote
//
//  Created by 이창현 on 10/26/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("검색", systemImage: "magnifyingglass") {
                SearchView()
            }
            Tab("워치리스트", systemImage: "bookmark") {
                NavigationStack {
                    ContentUnavailableView("준비 중이에요", systemImage: "bookmark")
                        .navigationTitle("워치리스트")
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}
