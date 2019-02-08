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
    func showArtistsSearch()
    func showAlbumDetails(album: Album)
    func dismiss()
}

class MainCollectionViewController: UICollectionViewController {
    
    var interactor: MainCollectionViewInteractor!
    weak var coordinator: MainCollectionViewCoordinator?
    
    private var albums: [AlbumCoreData] = []
    private let imageLoader = ImageCacheLoader()
    private let reuseIdentifier = "AlbumCell"
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 0.0,
                                             right: 20.0)
    private var backgroundView: UIImageView {
        let background = UIImageView()
        background.contentMode = .scaleAspectFill
        if albums.count == 0 {
            background.image = UIImage(named: "main_view")
        }
        return background
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        albums = CoreDataManager.shared.loadAlbums()
        collectionView.reloadData()
        collectionView.backgroundView = backgroundView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent { coordinator?.dismiss() }
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        coordinator?.showArtistsSearch()
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.coordinator?.stop()
        LastfmAuth.auth.logout()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FavouriteAlbumCell else { return UICollectionViewCell() }
        
        let album = albums[indexPath.row]
        
        if let data = album.image as Data? {
            cell.albumImageView.image = UIImage(data: data)
        } else if let imagePath = album.images?.extralarge {
            imageLoader.obtainImageWithPath(imagePath: imagePath) { (image, _) in
                cell.albumImageView.image = image
            }
        }
        
        cell.albumNameLabel.text = album.name
        cell.artistNameLabel.text = album.artist?.name
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let album = Album(albumCoreData: albums[indexPath.row]) {
            coordinator?.showAlbumDetails(album: album)
        }
    }
}

extension MainCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem * 1.2
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
