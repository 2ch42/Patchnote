//
//  AppDetail.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation

nonisolated struct AppDetail: Decodable, Identifiable, Sendable {
    let trackId: Int
    let trackName: String
    let sellerName: String
    let artworkUrl100: URL
    let artworkUrl512: URL
    let averageUserRating: Double?
    let userRatingCount: Int?
    let version: String
    let currentVersionReleaseDate: Date
    let releaseNotes: String?
    let fileSizeBytes: String
    let minimumOsVersion: String
    let trackViewUrl: URL

    var id: Int { trackId }
}
