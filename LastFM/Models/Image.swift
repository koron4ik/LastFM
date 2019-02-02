//
//  Image.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

enum ImageSize: String, Codable {
    case small
    case medium
    case large
    case extralarge
    case mega
}

class Image: Codable {
    
    let url: String
    let size: ImageSize
    
    enum CodingKeys: String, CodingKey {
        case url = "#text"
        case size
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.url = try container.decode(String.self, forKey: .url)
        self.size = try container.decode(ImageSize.self, forKey: .size)
    }
}
