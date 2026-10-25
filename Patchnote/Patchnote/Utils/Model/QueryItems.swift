//
//  QueryItems.swift
//  Patchnote
//
//  Created by 이창현 on 10/1/26.
//

import Foundation

enum QueryItems {
    
    case term(String)
    case country(String)
    case lang(String)
    case entity(String)
    case limit(Int)
    
    
    var queryItem: URLQueryItem {
        
        switch self {
        case .term(let term):
            return URLQueryItem(name: "term", value: term)
        case .country(let country):
            return URLQueryItem(name: "country", value: country)
        case .lang(let lang):
            return URLQueryItem(name: "lang", value: lang)
        case .entity(let entity):
            return URLQueryItem(name: "entity", value: entity)
        case .limit(let limit):
            return URLQueryItem(name: "limit", value: String(limit))
        }
    }
    
}
