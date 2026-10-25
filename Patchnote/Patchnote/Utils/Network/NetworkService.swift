//
//  NetworkService.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import Foundation

final class NetworkService {
    
    static func searchTerm(
        term: String
    ) {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "ITUNES_BASE_URL") as? String else {
            return
        }
        
        var url = URL(string: baseURL + "/search")
        
        let items: [QueryItems] = [
            .term(term),
            .entity("software"),
            .country("kr")
        ]
        let queryItems = items.map { $0.queryItem }
        
        url?.append(queryItems: queryItems)
        
        var request = URLRequest(url: url ?? URL(filePath: ""))
        request.httpMethod = HTTPMethod.get
        
        let session = URLSession(configuration: .ephemeral)
        
    }
}
