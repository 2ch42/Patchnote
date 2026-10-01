//
//  NetworkService.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import Foundation

final class NetworkService {
    
    static func request(
        requestDTO: Encodable,
        responseDTO: Decodable
    ) {
        let request = URLRequest(url: <#T##URL#>)
        URLSession.shared.dataTask(
            with: <#T##URLRequest#>,
            completionHandler: <#T##(Data?, URLResponse?, (any Error)?) -> Void#>
        )
    }
}
