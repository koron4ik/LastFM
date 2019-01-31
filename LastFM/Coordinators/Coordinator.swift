//
//  Coordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    
    var rootViewController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    
    /// Tells the coordinator to create its
    /// initial view controller and take over the user flow.
    func start()
    
    /// Tells the coordinator that it is done and that it should
    /// rewind the view controller state to where it was before `start` was called.
    func stop()
}

extension Coordinator {

    /// Add a child coordinator to the parent
    func add(childCoordinator: Coordinator) {
        self.childCoordinators.append(childCoordinator)
    }
    
    /// Remove a child coordinator from the parent
    func remove(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }
}
