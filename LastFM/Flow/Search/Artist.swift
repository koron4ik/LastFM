//
//  Artist.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

extension Decodable {
    var model: [Decodable] { return [] }
}

class ArtistsRoot: Decodable {
    
    enum ResultCodingKeys: String, CodingKey {
        case results
    }
    
    enum ArtistmatchesCodingKeys: String, CodingKey {
        case artistmatches
    }
    
    enum ArtistCodingKeys: String, CodingKey {
        case artists = "artist"
    }
    
    let artists: [Artist]
    
    required init(from decoder: Decoder) throws {
        let result = try decoder.container(keyedBy: ResultCodingKeys.self)
        let artistmatches = try result.nestedContainer(keyedBy: ArtistmatchesCodingKeys.self,
                                                       forKey: .results)
        let artist = try artistmatches.nestedContainer(keyedBy: ArtistCodingKeys.self,
                                                       forKey: .artistmatches)
        
        self.artists = try artist.decode([Artist].self, forKey: .artists)
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
