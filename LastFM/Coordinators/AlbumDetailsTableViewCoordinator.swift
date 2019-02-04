//
//  AlbumDetailsViewCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/3/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewCoordinator: Coordinator, AlbumDetailsTableViewControllerCoordinator {
    
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinator] = []
    lazy var presentingViewController: UIViewController = self.albumDetailsTableViewController()
    weak var delegate: FinishCoordinatorDelegate?
    private var album: Album
    
    init(rootViewController: UINavigationController, album: Album) {
        self.rootViewController = rootViewController
        self.album = album
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

extension AlbumDetailsTableViewCoordinator {
    
    private func albumDetailsTableViewController() -> AlbumDetailsTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "AlbumDetailsTableViewController") as? AlbumDetailsTableViewController else {
            preconditionFailure("Main Storyboard should contain AlbumDetailsTableViewController")
        }
        
        viewController.interactor = AlbumDetailsTableViewInteractor(album: album)
        viewController.coordinator = self
        
        return viewController
    }
}
