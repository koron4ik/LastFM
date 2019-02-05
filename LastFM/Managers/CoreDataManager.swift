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
    
    private func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    lazy var albumEntity = NSEntityDescription.entity(forEntityName: "AlbumCoreData",
                                                 in: self.managedObjectContext)!
    lazy var artistEntity = NSEntityDescription.entity(forEntityName: "ArtistCoreData",
                                                      in: self.managedObjectContext)!
    lazy var trackEntity = NSEntityDescription.entity(forEntityName: "TrackCoreData",
                                                      in: self.managedObjectContext)!
}

extension CoreDataManager {
    
    func saveAlbumToFavourite(_ album: Album, imageData: Data? = nil, tracks: [Track]? = nil) {
        let albumCoreData = AlbumCoreData(entity: albumEntity,
                                          insertInto: managedObjectContext)
        let artistCoreData = ArtistCoreData(entity: artistEntity,
                                            insertInto: managedObjectContext)
        
        artistCoreData.name = album.artist.name
        artistCoreData.url = album.artist.url
        
        albumCoreData.name = album.name
        albumCoreData.artist = artistCoreData
        albumCoreData.image = imageData
        albumCoreData.imageUrl = album.imageUrl[.extralarge]
        
        if let tracks = tracks {
            tracks.forEach {
                let track = TrackCoreData(entity: trackEntity,
                                          insertInto: managedObjectContext)
                
                track.name = $0.name
                track.duration = Int16($0.duration)
                albumCoreData.tracks?.adding(track)
            }
        }
        
        self.saveContext()
    }
    
    func albumIsExist(_ album: Album) -> Bool {
        let albums = self.loadAlbums()
        
        for item in albums {
            if item.name == album.name && item.artist?.name == album.artist.name {
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
                if result.name == album.name && result.artist?.name == album.artist.name {
                    managedObjectContext.delete(result)
                }
            }
        } catch let error as NSError {
            print("Delete route by ref in AlbumsCoreData error: \(error)")
        }
        self.saveContext()
    }
}
