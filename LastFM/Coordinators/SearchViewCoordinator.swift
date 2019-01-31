//
//  SearchTableViewCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class SearchViewCoordinator: Coordinator, SearchViewControllerCoordinator {
    
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinator] = []
    lazy var presentingViewController: UIViewController = self.searchViewController()
    weak var delegate: FinishCoordinatorDelegate?
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    func start() {
        self.rootViewController.pushViewController(self.searchViewController(), animated: true)
    }
    
    func stop() {
        self.rootViewController.popViewController(animated: true)
    }
    
    func dismiss() {
        self.delegate?.finishedFlow(coordinator: self)
    }
}

extension SearchViewCoordinator {
    
    private func searchViewController() -> SearchViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            preconditionFailure("Main Storyboard should contain SearchViewController")
        }
        
        viewController.interactor = SearchViewInteractor()
        viewController.coordinator = self
        
        return viewController
    }
}
