//
//  Album.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation
import CoreData

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

//class ImageUrl {
//    let small: String?
//    let medium: String?
//    let large: String?
//    let extralarge: String?
//    let mega: String?
//    
//    init(images: [Image2]) {
//        self.small = images[0].url
//        self.medium = images[1].url
//        self.large = images[2].url
//        self.extralarge = images[3].url
//        self.mega = images[4].url
//    }
//}

@objc(Album)
public class Album: NSManagedObject, Decodable {
    
   // let playcount: Int
    @NSManaged var name: String?
    @NSManaged var artist: Artist?
    @NSManaged var imageUrl: String?
    @NSManaged var image: NSData?
    @NSManaged var tracks: NSSet?
    
    var url: String?
    var images: Images?
    
    enum CodingKeys: String, CodingKey {
      //  case playcount
        case name
        case artist
        case url
        case images = "image"
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init(entity: CoreDataManager.shared.albumEntity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        self.images = try container.decode(Images.self, forKey: .images)
        self.artist = try container.decode(Artist.self, forKey: .artist)
        self.artist?.addAlbum(self)
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }
    
    func addTracks(_ tracks: [Track]) {
        if managedObjectContext != nil {
            for track in tracks {
                managedObjectContext?.insert(track)
            }
        }
        
        let tracksSet = self.mutableSetValue(forKey: "tracks")
        tracksSet.setSet(Set(tracks))
        for track in tracks {
            track.addAlbum(self)
        }
    }
    
    func addImageData(_ imageData: Data) {
        self.image = imageData as NSData
    }
}
