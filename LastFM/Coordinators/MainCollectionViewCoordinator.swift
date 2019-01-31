//
//  MainCollectionViewCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class MainCollectionViewCoordinator: Coordinator, MainCollectionViewControllerCoordinator {
    
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinator] = []
    lazy var presentingViewController: UIViewController = self.mainCollectionViewController()
    weak var delegate: FinishCoordinatorDelegate?
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    func start() {
        self.rootViewController.pushViewController(self.presentingViewController, animated: true)
    }
    
    func stop() {
        self.rootViewController.popViewController(animated: true)
    }
    
    func dismiss() {
        self.delegate?.finishedFlow(coordinator: self)
    }
}

extension MainCollectionViewCoordinator {
    
    private func mainCollectionViewController() -> MainCollectionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "MainCollectionViewController") as? MainCollectionViewController else {
            preconditionFailure("Main Storyboard should contain MainCollectionViewController")
        }
    
        viewController.interactor = MainCollectionViewInteractor()
        viewController.coordinator = self
        
        return viewController
    }
}
