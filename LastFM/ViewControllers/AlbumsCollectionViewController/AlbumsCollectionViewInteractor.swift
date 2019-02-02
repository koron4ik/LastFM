//
//  AlbumsCollectionViewInteractor.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumsCollectionViewInteractor: AlbumsCollectionViewControllerIntercator {
    
    var artist: Artist
    
    init(artist: Artist) {
        self.artist = artist
    }
}
