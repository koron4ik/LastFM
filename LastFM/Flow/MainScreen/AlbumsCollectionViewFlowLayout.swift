//
//  AlbumsCollectionViewFlowLayout.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/13/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumsColletionViewFlowLayout: UICollectionViewFlowLayout {
    
    init(frame: CGRect, itemsPerRow: Int) {
        super.init()
        
        self.minimumLineSpacing = 20.0
        self.sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        let paddingSpace = sectionInset.left * CGFloat(itemsPerRow + 1)
        let availableWidth = frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        let heightPerItem = widthPerItem * 1.2
        
        self.itemSize = CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
