//
//  User.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class Session: Decodable {
    
    var name: String
    var key: String
    
    enum SessionCodingKey: String, CodingKey {
        case session
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case key
    }
    
    required init(from decoder: Decoder) throws {
        let session = try decoder.container(keyedBy: SessionCodingKey.self)
        let container = try session.nestedContainer(keyedBy: CodingKeys.self, forKey: .session)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.key = try container.decode(String.self, forKey: .key)
    }
}
