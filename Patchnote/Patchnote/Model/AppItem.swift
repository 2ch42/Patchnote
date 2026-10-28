//
//  AppItem.swift
//  Patchnote
//
//  Created by 이창현 on 10/26/26.
//

import Foundation

nonisolated struct AppItem: Decodable, Identifiable, Sendable {
    let trackId: Int
    let trackName: String
    let sellerName: String
    let artworkUrl100: URL
    let averageUserRating: Double?
    let userRatingCount: Int?

    var id: Int { trackId }
}
