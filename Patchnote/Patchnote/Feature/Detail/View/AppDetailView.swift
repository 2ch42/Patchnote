//
//  AppDetailView.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import SwiftUI

struct AppDetailView: View {
    @State private var viewModel: AppDetailViewModel

    init(trackId: Int) {
        _viewModel = State(initialValue: AppDetailViewModel(trackId: trackId))
    }

    var body: some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(
                    viewModel.isWatched ? "워치리스트에서 제거" : "워치리스트에 추가",
                    systemImage: viewModel.isWatched ? "bookmark.fill" : "bookmark"
                ) {
                    viewModel.toggleWatch()
                }
            }
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .notFound:
            ContentUnavailableView("스토어에서 찾을 수 없어요", systemImage: "questionmark.app")
        case .failed(let message):
            ContentUnavailableView {
                Label("불러오지 못했어요", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("다시 시도") { Task { await viewModel.load() } }
            }
        case .loaded(let detail):
            detailBody(detail)
        }
    }

    private func detailBody(_ detail: AppDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    AsyncImage(url: detail.artworkUrl512) { image in
                        image.resizable()
                    } placeholder: {
                        Color(.systemFill)
                    }
                    .frame(width: 96, height: 96)
                    .clipShape(.rect(cornerRadius: 22))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(detail.trackName).font(.title2.bold())
                        Text(detail.sellerName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    infoRow("버전", detail.version)
                    infoRow("업데이트", detail.currentVersionReleaseDate.formatted(.relative(presentation: .named)))
                    infoRow("크기", fileSizeText(detail.fileSizeBytes))
                    infoRow("최소 iOS", detail.minimumOsVersion)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("릴리스 노트").font(.headline)
                    Text(releaseNotesText(detail.releaseNotes))
                        .foregroundStyle(.secondary)
                }

                Link("App Store에서 보기", destination: detail.trackViewUrl)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }

    private func fileSizeText(_ bytes: String) -> String {
        guard let value = Int64(bytes) else { return "-" }
        return ByteCountFormatter.string(fromByteCount: value, countStyle: .file)
    }

    private func releaseNotesText(_ notes: String?) -> String {
        guard let notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "릴리스 노트 없음"
        }
        return notes
    }
}
