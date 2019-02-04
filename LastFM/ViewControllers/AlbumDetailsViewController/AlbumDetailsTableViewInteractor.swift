//
//  AlbumDetailsViewInteractor.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/3/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewInteractor: AlbumDetailsTableViewControllerInteractor {
    
    var album: Album
    
    init(album: Album) {
        self.album = album
    }
}
