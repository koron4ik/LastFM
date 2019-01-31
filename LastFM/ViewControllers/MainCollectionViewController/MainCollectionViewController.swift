//
//  MainViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol MainCollectionViewControllerInteractor: class {
    
}

protocol MainCollectionViewControllerCoordinator: class {
    
}

class MainCollectionViewController: UICollectionViewController {
    
    var interactor: MainCollectionViewInteractor!
    weak var coordinator: MainCollectionViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
