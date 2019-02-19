//
//  Track.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class TracksRoot: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case album
        case tracks
        case track
    }
    
    let tracks: [Track]
    
    required init(from decoder: Decoder) throws {
        let album = try decoder.container(keyedBy: CodingKeys.self)
        let tracks = try album.nestedContainer(keyedBy: CodingKeys.self,
                                                       forKey: .album)
        let track = try tracks.nestedContainer(keyedBy: CodingKeys.self, forKey: .tracks)
        
        self.tracks = try track.decode([Track].self, forKey: .track)
    }
}

class Track: Decodable {
    
    var name: String?
    
    init?(trackCoreData: TrackCoreData) {
        self.name = trackCoreData.name
    }
    
}
