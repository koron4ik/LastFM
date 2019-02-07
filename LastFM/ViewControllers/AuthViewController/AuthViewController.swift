//
//  AuthViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol AuthViewControllerInteractor: class {
    
}

protocol AuthViewControllerCoordinator: class {
    func showMainScreen()
}

class AuthViewController: UIViewController {
    
    var interactor: AuthViewInteractor!
    weak var coordinator: AuthViewCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
}
