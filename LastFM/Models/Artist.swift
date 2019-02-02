//
//  Artist.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class ArtistsRoot: Codable {
    
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

class Artist: Codable {
    
    let listeners: Int
    let name: String
    let mbid: String
    let url: String
    
    private let images: [Image]
    lazy var imageUrl: [ImageSize: String] = [
        .small: images[0].url,
        .medium: images[1].url,
        .large: images[2].url,
        .extralarge: images[3].url,
        .mega: images[4].url
    ]

    enum CodingKeys: String, CodingKey {
        case listeners
        case name
        case mbid
        case url
        case images = "image"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.listeners = Int(try container.decode(String.self, forKey: .listeners)) ?? 0
        self.name = try container.decode(String.self, forKey: .name)
        self.mbid = try container.decode(String.self, forKey: .mbid)
        self.url = try container.decode(String.self, forKey: .url)
        self.images = try container.decode([Image].self, forKey: .images)
    }
}
