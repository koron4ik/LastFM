//
//  Track.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation
import CoreData

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

@objc(Track)
class Track: NSManagedObject, Decodable {
    
    @NSManaged var name: String?
    @NSManaged var duration: NSNumber?
    
    enum CodingKeys: String, CodingKey {
        case name
        case duration
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init(entity: CoreDataManager.shared.trackEntity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.duration = Int(try container.decode(String.self, forKey: .duration))! as NSNumber
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }
}
