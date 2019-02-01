//
//  Track.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

struct Track: Decodable {
    
    var name: String
    var artist: String
    var url: String
}
