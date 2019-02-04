//
//  AlbumsCollectionViewCoordinator.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumsCollectionViewCoordinator: Coordinator, AlbumsCollectionViewControllerCoordinator {
    
    var rootViewController: UINavigationController
    var childCoordinators: [Coordinator] = []
    lazy var presentingViewController: UIViewController = self.albumsCollectionViewController()
    weak var delegate: FinishCoordinatorDelegate?
    private var artist: Artist
    
    init(rootViewController: UINavigationController, artist: Artist) {
        self.rootViewController = rootViewController
        self.artist = artist
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
    
    func showAlbumDetails(album: Album) {
        let albumDetailsTableViewCoordinator = AlbumDetailsTableViewCoordinator(rootViewController: rootViewController, album: album)
        self.add(childCoordinator: albumDetailsTableViewCoordinator)
        albumDetailsTableViewCoordinator.delegate = self
        albumDetailsTableViewCoordinator.start()
    }
}

extension AlbumsCollectionViewCoordinator {
    
    private func albumsCollectionViewController() -> AlbumsCollectionViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "AlbumsCollectionViewController") as? AlbumsCollectionViewController else {
            preconditionFailure("Main Storyboard should contain AlbumsCollectionViewController")
        }
        
        viewController.interactor = AlbumsCollectionViewInteractor(artist: artist)
        viewController.coordinator = self
        
        return viewController
    }
}

extension AlbumsCollectionViewCoordinator: FinishCoordinatorDelegate {
    
    func finishedFlow(coordinator: Coordinator) {
        self.remove(childCoordinator: coordinator)
    }
}
