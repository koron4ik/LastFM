//
//  URLComponents+setQueryItems.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/6/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

extension URLComponents {
    
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
