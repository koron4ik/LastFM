//
//  FavouriteAlbumCell.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/4/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class FavouriteAlbumCell: UICollectionViewCell {
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        albumImageView.image = nil
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        layer.borderWidth = 0.0
        checkMarkImageView.isHidden = true
    }
}
