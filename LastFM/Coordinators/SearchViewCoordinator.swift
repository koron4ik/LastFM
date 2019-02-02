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
        self.rootViewController.pushViewController(self.presentingViewController, animated: true)
    }
    
    func stop() {
        self.rootViewController.popViewController(animated: true)
    }
    
    func dismiss() {
        self.delegate?.finishedFlow(coordinator: self)
    }
    
    func showAlbums(artist: Artist) {
        let albumsCollectionViewController = AlbumsCollectionViewCoordinator(rootViewController: rootViewController, artist: artist)
        self.add(childCoordinator: albumsCollectionViewController)
        albumsCollectionViewController.delegate = self
        albumsCollectionViewController.start()
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

extension SearchViewCoordinator: FinishCoordinatorDelegate {
    
    func finishedFlow(coordinator: Coordinator) {
        self.remove(childCoordinator: coordinator)
    }
}
