//
//  UITextField+setIcon.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/14/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setRightButtonView(_ button: UIButton) {
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 5, width: 30, height: 30))
        iconContainerView.addSubview(button)
        
        rightView = iconContainerView
        rightViewMode = .always
    }
    
}
