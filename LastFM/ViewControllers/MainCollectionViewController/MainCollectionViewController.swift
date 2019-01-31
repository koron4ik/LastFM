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
    func showSearchViewController()
    func dismiss()
}

class MainCollectionViewController: UICollectionViewController {
    
    var interactor: MainCollectionViewInteractor!
    weak var coordinator: MainCollectionViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.dismiss()
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        coordinator?.showSearchViewController()
    }
    
}
