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
    var imageData: Data?
    var tracks: [Track]?
    
    var url: String?
    var image: Images?
    
    init?(albumCoreData: AlbumCoreData) {
        self.name = albumCoreData.name
        self.imageData = albumCoreData.image
            
        if let artist = albumCoreData.artist {
            self.artist = Artist(artistCoreData: artist)
        }
        
        if let images = albumCoreData.images {
            self.image = Images(imageCoreData: images)
        }
        
        if let tracks = albumCoreData.tracks?.array as? [TrackCoreData] {
            self.tracks = tracks.compactMap({ Track(trackCoreData: $0) })
        }
    }

    func addTracks(_ tracks: [Track]) {
        self.tracks = tracks
    }
    
    func addImage(_ image: UIImage?) {
        self.imageData = image?.pngData()
    }
}
