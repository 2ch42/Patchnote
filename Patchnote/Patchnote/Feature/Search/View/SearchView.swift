//
//  SearchView.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("검색")
                .searchable(text: $viewModel.searchKeyword, prompt: "앱 검색")
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView("앱을 검색해 보세요", systemImage: "magnifyingglass")
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView.search(text: viewModel.searchKeyword)
        case .failed(let message):
            ContentUnavailableView("불러오지 못했어요", systemImage: "wifi.exclamationmark", description: Text(message))
        case .loaded(let items):
            List(items) { item in
                SearchResultRow(item: item)
            }
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    SearchView()
}
