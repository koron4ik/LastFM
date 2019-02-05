//
//  AlbumCell.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol AlbumCellDelegate: class {
    func albumCell(_ albumCell: AlbumCell, favouriteButtonPressedAt indexPath: IndexPath)
}

class AlbumCell: UICollectionViewCell {
    
    weak var delegate: AlbumCellDelegate?
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var favouriteAlbumButton: UIButton!
    
    var indexPath: IndexPath!
    var isFavourite: Bool = false {
        didSet {
            let image = isFavourite ? UIImage(named: "favourite") : UIImage(named: "unfavourite")
            favouriteAlbumButton.setImage(image, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isFavourite = false
        albumImageView.image = UIImage(named: "music_placeholder")
        albumNameLabel.text = nil
    }
    
    @IBAction func favouriteAlbumButtonPressed(_ sender: Any) {
        delegate?.albumCell(self, favouriteButtonPressedAt: indexPath)
        isFavourite = !isFavourite
    }
    
}
