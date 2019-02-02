//
//  AlbumCell.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol AlbumCellDelegate: class {
    func favouritesPressed(_ albumCell: AlbumCell)
}

class AlbumCell: UICollectionViewCell {
    
    weak var delegate: AlbumCellDelegate?
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var favouriteAlbumButton: UIButton!
    
    @IBAction func favouriteAlbumButtonPressed(_ sender: Any) {
        delegate?.favouritesPressed(self)
    }
    
}
