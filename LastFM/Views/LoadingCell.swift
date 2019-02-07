//
//  LoadingCell.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/6/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    var activityIndicator: UIActivityIndicatorView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
    }
}
