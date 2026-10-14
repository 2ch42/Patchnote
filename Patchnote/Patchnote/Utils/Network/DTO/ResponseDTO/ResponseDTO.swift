//
//  ResponseDTO.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import Foundation

struct Envelope: Codable {
    
    let resultCount: Int
    let results: [ResultsInfo]
    
    struct ResultsInfo: Codable { }
}
