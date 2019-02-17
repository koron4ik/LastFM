//
//  Track.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class TracksRoot: Decodable {
    
    enum AlbumCodingKeys: String, CodingKey {
        case album
    }
    
    enum TracksCodingKeys: String, CodingKey {
        case tracks
    }
    
    enum TrackCodingKeys: String, CodingKey {
        case track
    }
    
    let tracks: [Track]
    
    required init(from decoder: Decoder) throws {
        let album = try decoder.container(keyedBy: AlbumCodingKeys.self)
        let tracks = try album.nestedContainer(keyedBy: TracksCodingKeys.self,
                                                       forKey: .album)
        let track = try tracks.nestedContainer(keyedBy: TrackCodingKeys.self, forKey: .tracks)
        
        self.tracks = try track.decode([Track].self, forKey: .track)
    }
}

class Track: Decodable {
    
    var name: String?
    
    init?(trackCoreData: TrackCoreData) {
        self.name = trackCoreData.name
    }
    
}
