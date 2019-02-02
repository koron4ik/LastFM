//
//  Album.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class AlbumsRoot: Codable {
    
    enum ResultCodingKeys: String, CodingKey {
        case topalbums
    }
    
    enum AlbumsCodingKeys: String, CodingKey {
        case albums = "album"
    }
    
    let albums: [Album]
    
    required init(from decoder: Decoder) throws {
        let topalbums = try decoder.container(keyedBy: ResultCodingKeys.self)
        let album = try topalbums.nestedContainer(keyedBy: AlbumsCodingKeys.self, forKey: .topalbums)
        
        self.albums = try album.decode([Album].self, forKey: .albums)
    }
}

class Album: Codable {
    
    let playcount: Int
    let name: String
    //let artist: Artist
    let mbid: String?
    let url: String
    
    private let images: [Image]
    lazy var imageUrl: [ImageSize: String] = [
        .small: images[0].url,
        .medium: images[1].url,
        .large: images[2].url,
        .extralarge: images[3].url
    ]
    
    enum CodingKeys: String, CodingKey {
        case playcount
        case name
        //case artist
        case mbid
        case url
        case images = "image"
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.name = try container.decode(String.self, forKey: .name)
//        self.mbid = try container.decode(String.self, forKey: .mbid)
//        self.url = try container.decode(String.self, forKey: .url)
//        //self.images = try container.decode([Image].self, forKey: .images)
//        //self.artist = try container.decode(Artist.self, forKey: .artist)
//    }
}
