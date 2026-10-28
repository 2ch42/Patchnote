//
//  WatchlistStore.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation

@MainActor
final class WatchlistStore {
    static let shared = WatchlistStore()

    private let defaults = UserDefaults.standard
    private let key = "watchlist"

    private init() {}

    var items: [WatchedApp] {
        guard let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([WatchedApp].self, from: data) else { return [] }
        return items
    }

    func contains(_ trackId: Int) -> Bool {
        items.contains { $0.trackId == trackId }
    }

    func add(trackId: Int, version: String) {
        guard !contains(trackId) else { return }
        save(items + [WatchedApp(trackId: trackId, version: version, savedAt: .now)])
    }

    func remove(_ trackId: Int) {
        save(items.filter { $0.trackId != trackId })
    }

    func updateVersion(_ trackId: Int, to version: String) {
        save(items.map {
            guard $0.trackId == trackId else { return $0 }
            var updated = $0
            updated.version = version
            return updated
        })
    }

    private func save(_ items: [WatchedApp]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }
}
