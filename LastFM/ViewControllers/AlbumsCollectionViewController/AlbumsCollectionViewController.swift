//
//  AlbumsCollectionViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol AlbumsCollectionViewControllerIntercator: class {
    var artist: Artist { get }
}

protocol AlbumsCollectionViewControllerCoordinator: class {
    func showAlbumDetails(album: Album)
    func dismiss()
}

class AlbumsCollectionViewController: UICollectionViewController {
    
    var interactor: AlbumsCollectionViewInteractor!
    weak var coordinator: AlbumsCollectionViewCoordinator?
    
    private var albums: [Album] = []
    private var imageLoader: ImageCacheLoader = ImageCacheLoader()
    private let reuseIdentifier = "AlbumCell"
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 20.0,
                                             left: 20.0,
                                             bottom: 0.0,
                                             right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkManager.getTopAlbums(artistName: interactor.artist.name) { [weak self] (result) in
            switch result {
            case .success(let albums):
                guard let albums = albums else { return }
                self?.albums = albums
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.dismiss()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? AlbumCell else { return UICollectionViewCell() }
        
        let album = albums[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.albumNameLabel.text = album.name
        
        if CoreDataManager.shared.albumIsExist(album) {
            cell.isFavourite = true
        }
        
        imageLoader.obtainImageWithPath(imagePath: album.imagesUrl?[.large] ?? "") { (image, _) in
            //if let updateCell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                cell.albumImageView.image = image
            //}
        }
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.showAlbumDetails(album: albums[indexPath.row])
    }
}

extension AlbumsCollectionViewController: AlbumCellDelegate {
    
    func albumCell(_ albumCell: AlbumCell, favouriteButtonPressedAt indexPath: IndexPath) {
        if albumCell.isFavourite {
            CoreDataManager.shared.deleteAlbum(albums[indexPath.row])
        } else {
            CoreDataManager.shared.saveAlbumToFavourite(albums[indexPath.row])
        }
    }
}

extension AlbumsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem = widthPerItem * 1.1
        
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
