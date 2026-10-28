//
//  WatchlistViewModel.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation
import Observation

// MARK: - Properties
@MainActor
@Observable
final class WatchlistViewModel {
    struct Row: Identifiable {
        let watched: WatchedApp
        /// 스토어에서 내려간 앱은 nil
        let app: AppDetail?

        var id: Int { watched.trackId }

        var hasNewVersion: Bool {
            guard let app else { return false }
            return watched.hasNewVersion(latest: app.version)
        }
    }

    enum State {
        case loading
        case empty
        case loaded([Row])
        case failed(String)
    }

    private(set) var state: State = .loading
    private let store = WatchlistStore.shared
}

// MARK: - Methods
extension WatchlistViewModel {
    func load() async {
        let watched = store.items
        guard !watched.isEmpty else {
            state = .empty
            return
        }
        do {
            let apps = try await lookup(ids: watched.map(\.trackId))
            let appsById = Dictionary(uniqueKeysWithValues: apps.map { ($0.trackId, $0) })
            state = .loaded(watched.map { Row(watched: $0, app: appsById[$0.trackId]) })
        } catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            state = .failed("네트워크 상태를 확인하고 다시 시도해 주세요.")
        }
    }

    func remove(trackId: Int) {
        store.remove(trackId)
        guard case .loaded(let rows) = state else { return }
        let remaining = rows.filter { $0.id != trackId }
        state = remaining.isEmpty ? .empty : .loaded(remaining)
    }
}

private extension WatchlistViewModel {
    func lookup(ids: [Int]) async throws -> [AppDetail] {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "ITUNES_BASE_URL") as? String ?? ""
        guard var components = URLComponents(string: baseURL) else { throw URLError(.badURL) }
        components.path = "/lookup"
        components.queryItems = [
            URLQueryItem(name: "id", value: ids.map(String.init).joined(separator: ",")),
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
        return try decoder.decode(LookupResponse.self, from: data).results
    }
}
