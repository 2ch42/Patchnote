//
//  AppDetailViewModel.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation
import Observation

// MARK: - Properties
@MainActor
@Observable
final class AppDetailViewModel {
    enum State {
        case loading
        case loaded(AppDetail)
        case notFound
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var isWatched: Bool

    private let trackId: Int
    private let store = WatchlistStore.shared

    init(trackId: Int) {
        self.trackId = trackId
        self.isWatched = WatchlistStore.shared.contains(trackId)
    }
}

// MARK: - Methods
extension AppDetailViewModel {
    func load() async {
        state = .loading
        do {
            guard let detail = try await lookup() else {
                state = .notFound
                return
            }
            // 조회에 성공한 뒤에만 "확인함"으로 처리한다.
            if store.contains(trackId) {
                store.updateVersion(trackId, to: detail.version)
            }
            state = .loaded(detail)
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            state = .failed("네트워크 상태를 확인하고 다시 시도해 주세요.")
        }
    }

    func toggleWatch() {
        guard case .loaded(let detail) = state else { return }
        if isWatched {
            store.remove(trackId)
        } else {
            store.add(trackId: trackId, version: detail.version)
        }
        isWatched = store.contains(trackId)
    }
}

private extension AppDetailViewModel {
    func lookup() async throws -> AppDetail? {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "ITUNES_BASE_URL") as? String ?? ""
        guard var components = URLComponents(string: baseURL) else { throw URLError(.badURL) }
        components.path = "/lookup"
        components.queryItems = [
            URLQueryItem(name: "id", value: String(trackId)),
            URLQueryItem(name: "country", value: "kr"),
            URLQueryItem(name: "lang", value: "ko_kr")
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(LookupResponse.self, from: data).results.first
    }
}
