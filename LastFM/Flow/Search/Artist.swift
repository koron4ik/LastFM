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
    var images: Images?

    enum CodingKeys: String, CodingKey {
        case name
        case url
        case images = "image"
    }
    
    init?(artistCoreData: ArtistCoreData) {
        self.name = artistCoreData.name
        self.url = artistCoreData.url
        
        if let images = artistCoreData.images {
            self.images = Images(imageCoreData: images)
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.images = try container.decodeIfPresent(Images.self, forKey: .images)
    }
}
