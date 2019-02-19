//
//  Artist.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class ArtistsRoot: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case results
        case artistmatches
        case artists = "artist"
    }
    
    let artists: [Artist]
    
    required init(from decoder: Decoder) throws {
        let result = try decoder.container(keyedBy: CodingKeys.self)
        let artistmatches = try result.nestedContainer(keyedBy: CodingKeys.self,
                                                       forKey: .results)
        let artists = try artistmatches.nestedContainer(keyedBy: CodingKeys.self,
                                                       forKey: .artistmatches)
        
        self.artists = try artists.decode([Artist].self, forKey: .artists)
    }
}

class Artist: Decodable {
    
    var name: String?
    var url: String?
    var image: Images?
    
    init?(artistCoreData: ArtistCoreData) {
        self.name = artistCoreData.name
        self.url = artistCoreData.url
        
        if let images = artistCoreData.images {
            self.image = Images(imageCoreData: images)
        }
    }
}
