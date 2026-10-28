//
//  WatchlistView.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import SwiftUI

struct WatchlistView: View {
    @State private var viewModel = WatchlistViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("워치리스트")
                .task { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .empty:
            ContentUnavailableView("관심 앱을 추가해 보세요", systemImage: "bookmark")
        case .failed(let message):
            ContentUnavailableView {
                Label("불러오지 못했어요", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("다시 시도") { Task { await viewModel.load() } }
            }
        case .loaded(let rows):
            List {
                ForEach(rows) { row in
                    rowView(row)
                }
                .onDelete { offsets in
                    offsets.map { rows[$0].id }.forEach(viewModel.remove(trackId:))
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    @ViewBuilder
    private func rowView(_ row: WatchlistViewModel.Row) -> some View {
        if let app = row.app {
            NavigationLink {
                AppDetailView(trackId: app.trackId)
            } label: {
                WatchlistRow(app: app, hasNewVersion: row.hasNewVersion)
            }
        } else {
            Label("스토어에서 찾을 수 없음 (ID \(row.id))", systemImage: "questionmark.app")
                .foregroundStyle(.secondary)
        }
    }
}

private struct WatchlistRow: View {
    let app: AppDetail
    let hasNewVersion: Bool

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: app.artworkUrl100) { image in
                image.resizable()
            } placeholder: {
                Color(.systemFill)
            }
            .frame(width: 56, height: 56)
            .clipShape(.rect(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 2) {
                Text(app.trackName)
                    .font(.headline)
                    .lineLimit(1)
                Text("v\(app.version)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if hasNewVersion {
                Text("새 버전")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.tint, in: .capsule)
                    .foregroundStyle(.white)
            }
        }
        .padding(.vertical, 4)
    }
}
