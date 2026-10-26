//
//  SearchViewModel.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import Foundation
import Observation

// MARK: - Properties
@MainActor
@Observable
final class SearchViewModel {
    enum State {
        case idle
        case loading
        case loaded([AppItem])
        case empty
        case failed(String)
    }

    private(set) var state: State = .idle
    private var searchTask: Task<Void, Never>?

    var searchKeyword: String = "" {
        didSet { keywordDidChange() }
    }
}

// MARK: - Methods
private extension SearchViewModel {
    func keywordDidChange() {
        searchTask?.cancel()

        let term = searchKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            state = .idle
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(400))
                state = .loading
                let items = try await search(term: term)
                guard !Task.isCancelled else { return }
                state = items.isEmpty ? .empty : .loaded(items)
            } catch is CancellationError {
                return
            } catch let error as URLError where error.code == .cancelled {
                return
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed("네트워크 상태를 확인하고 다시 시도해 주세요.")
            }
        }
    }

    func search(term: String) async throws -> [AppItem] {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "ITUNES_BASE_URL") as? String ?? ""
        guard var components = URLComponents(string: baseURL) else { throw URLError(.badURL) }
        components.path = "/search"
        components.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "entity", value: "software"),
            URLQueryItem(name: "country", value: "kr"),
            URLQueryItem(name: "limit", value: "25"),
            URLQueryItem(name: "lang", value: "ko_kr")
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(SearchResponse.self, from: data).results
    }
}
