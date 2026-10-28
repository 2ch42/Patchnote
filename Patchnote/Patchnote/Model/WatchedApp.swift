//
//  WatchedApp.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation

nonisolated struct WatchedApp: Codable, Identifiable, Sendable {
    let trackId: Int
    var version: String
    let savedAt: Date

    var id: Int { trackId }

    func hasNewVersion(latest: String) -> Bool {
        version != latest
    }
}
