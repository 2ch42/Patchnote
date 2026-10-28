//
//  LookupResponse.swift
//  Patchnote
//
//  Created by 이창현 on 10/28/26.
//

import Foundation

nonisolated struct LookupResponse: Decodable {
    let resultCount: Int
    let results: [AppDetail]
}
