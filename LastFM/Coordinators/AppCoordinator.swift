//
//  AppCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol FinishCoordinatorDelegate: class {
    func finishedFlow(coordinator: Coordinator)
}

class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var window: UIWindow?
    lazy var rootViewController = UINavigationController()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window?.rootViewController = self.rootViewController
        window?.makeKeyAndVisible()
        
        showAuth()
    }
    
    func stop() {
        window?.rootViewController = nil
        window?.makeKeyAndVisible()
    }
    
    func showAuth() {
        let authViewCoordinator = AuthViewCoordinator(rootViewController: self.rootViewController)
        
        self.add(childCoordinator: authViewCoordinator)
        authViewCoordinator.delegate = self
        authViewCoordinator.start()
    }
}

extension AppCoordinator: FinishCoordinatorDelegate {
    
    func finishedFlow(coordinator: Coordinator) {
        self.remove(childCoordinator: coordinator)
    }
}
