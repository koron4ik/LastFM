//
//  Album.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumsRoot: Decodable {
    
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

class Album: Decodable {
    
    var name: String?
    var artist: Artist?
    var image: UIImage?
    var tracks: [Track]?
    
    var url: String?
    var images: Images?
    
    enum CodingKeys: String, CodingKey {
        case name
        case artist
        case url
        case images = "image"
    }
    
    init?(albumCoreData: AlbumCoreData) {
        self.name = albumCoreData.name
        
        if let imageData = albumCoreData.image {
            self.image = UIImage(data: imageData)
        }
        
        if let artist = albumCoreData.artist {
            self.artist = Artist(artistCoreData: artist)
        }
        
        if let images = albumCoreData.images {
            self.images = Images(imageCoreData: images)
        }
        
        if let tracks = albumCoreData.tracks?.allObjects as? [TrackCoreData] {
            self.tracks = tracks.compactMap({ Track(trackCoreData: $0) })
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.images = try container.decode(Images.self, forKey: .images)
        self.artist = try container.decode(Artist.self, forKey: .artist)
    }

    func addTracks(_ tracks: [Track]) {
        self.tracks = tracks
    }
    
    func addImage(_ image: UIImage?) {
        self.image = image
    }
}
