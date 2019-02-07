//
//  AuthVIewCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/7/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AuthViewCoordinator: Coordinator, AuthViewControllerCoordinator {
    
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinator] = []
    lazy var presentingViewController: UIViewController = self.authViewController()
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
    
    func showMainScreen() {
        let mainCollectionViewCoordinator = MainCollectionViewCoordinator(rootViewController: self.rootViewController)
        
        self.add(childCoordinator: mainCollectionViewCoordinator)
        mainCollectionViewCoordinator.delegate = self
        mainCollectionViewCoordinator.start()
    }
    
}

extension AuthViewCoordinator {
    
    private func authViewController() -> AuthViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            preconditionFailure("Main Storyboard should contain AuthViewController")
        }
        
        viewController.interactor = AuthViewInteractor()
        viewController.coordinator = self
        
        return viewController
    }
}

extension AuthViewCoordinator: FinishCoordinatorDelegate {
    
    func finishedFlow(coordinator: Coordinator) {
        self.remove(childCoordinator: coordinator)
    }
}
