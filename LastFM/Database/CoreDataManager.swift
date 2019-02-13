//
//  CoreDataManager.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/3/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let objectModelName = "DataModel"
    private let objectModelExtension = "momd"
    
    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.objectModelName,
                                             withExtension: self.objectModelExtension) else {
                                                fatalError("Unable to Find Data Model")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to Load Data Model")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "\(self.objectModelName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    private init() {}
    
    private func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func entityForName(_ name: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: name, in: managedObjectContext)!
    }
}

extension CoreDataManager {
    
    func saveAlbumToFavourite(_ album: Album) {
        let albumCoreData = AlbumCoreData(entity: entityForName("AlbumCoreData"),
                                          insertInto: managedObjectContext)
        albumCoreData.name = album.name
        albumCoreData.image = album.image?.pngData()
        
        let albumImagesCoreData = ImagesCoreData(entity: entityForName("ImagesCoreData"),
                                                 insertInto: managedObjectContext)
        albumImagesCoreData.small = album.images?.small?.absoluteString
        albumImagesCoreData.medium = album.images?.medium?.absoluteString
        albumImagesCoreData.large = album.images?.large?.absoluteString
        albumImagesCoreData.extralarge = album.images?.extralarge?.absoluteString
        albumImagesCoreData.mega = album.images?.mega?.absoluteString
        albumCoreData.images = albumImagesCoreData
        
        let artistCoreData = ArtistCoreData(entity: entityForName("ArtistCoreData"),
                                            insertInto: managedObjectContext)
        artistCoreData.name = album.artist?.name
        artistCoreData.url = album.artist?.url
    
        let artistImagesCoreData = ImagesCoreData(entity: entityForName("ImagesCoreData"),
                                                  insertInto: managedObjectContext)
        artistImagesCoreData.small = album.images?.small?.absoluteString
        artistImagesCoreData.medium = album.images?.medium?.absoluteString
        artistImagesCoreData.large = album.images?.large?.absoluteString
        artistImagesCoreData.extralarge = album.images?.extralarge?.absoluteString
        artistImagesCoreData.mega = album.images?.mega?.absoluteString
        artistCoreData.images = artistImagesCoreData
        albumCoreData.artist = artistCoreData
        
        if let tracks = album.tracks {
            for track in tracks {
                let trackCoreData = TrackCoreData(entity: entityForName("TrackCoreData"),
                                          insertInto: managedObjectContext)
                
                trackCoreData.name = track.name
                trackCoreData.duration = Int16(track.duration ?? 0)
                albumCoreData.addToTracks(trackCoreData)
            }
        }
        
        self.saveContext()
    }
    
    func updateAlbum(_ album: Album) {
        deleteAlbum(album)
        saveAlbumToFavourite(album)
    }
    
    func albumIsExist(_ album: Album) -> Bool {
        let albums = self.loadAlbums()
        for item in albums {
            if item.name == album.name && item.artist?.name == album.artist?.name {
                return true
            }
        }
        
        return false
    }
    
    func loadAlbums() -> [AlbumCoreData] {
        let fetchRequest = NSFetchRequest<AlbumCoreData>(entityName: "AlbumCoreData")
        var fetchResult = [AlbumCoreData]()
        do {
            fetchResult = try self.managedObjectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return fetchResult
    }
    
    func deleteAlbum(_ album: Album) {
        let fetchRequest = NSFetchRequest<AlbumCoreData>(entityName: "AlbumCoreData")
        var fetchResults = [AlbumCoreData]()
        do {
            fetchResults = try managedObjectContext.fetch(fetchRequest)
            for result in fetchResults {
                if result.name == album.name && result.artist?.name == album.artist?.name {
                    managedObjectContext.delete(result)
                }
            }
        } catch let error as NSError {
            print("Delete album error: \(error)")
        }
        self.saveContext()
    }
}

//print(NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
