//
//  LastFMAPI.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class LastFMAPIConfiguration {
    
    static let shared = LastFMAPIConfiguration()
    
    var apiKey: String?
    
    func provide(apiKey: String) {
        self.apiKey = apiKey
    }
}
