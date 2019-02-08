//
//  LastfmAPIConfiguration.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/8/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class LastfmAPIConfiguration {
    
    static let shared = LastfmAPIConfiguration()
    
    private init() { }
    
    var apiKey: String?
    var apiSecret: String?
    
    func configure(apiKey: String, apiSecret: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }
}
