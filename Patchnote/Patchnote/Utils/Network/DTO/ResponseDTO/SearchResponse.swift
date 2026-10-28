//
//  SearchResponse.swift
//  Patchnote
//
//  Created by 이창현 on 10/26/26.
//

import Foundation

nonisolated struct SearchResponse: Decodable {
    let resultCount: Int
    let results: [AppItem]
}
