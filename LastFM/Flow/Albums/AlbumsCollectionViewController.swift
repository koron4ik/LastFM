//
//  AlbumsCollectionViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumsCollectionViewController: UICollectionViewController {
    
    var artist: Artist!
    private var albums: [Album] = []
    private var imageLoader = ImageCacheLoader()
    private let reuseIdentifier = "AlbumCell"
    private var currentPage = 1
    private let numberOfPages = 3
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.collectionViewLayout = AlbumsColletionViewFlowLayout(frame: view.frame, itemsPerRow: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPage = 0
        albums.removeAll()
        collectionView.reloadData()
        loadAlbums()
    }
    
    private func loadAlbums() {
        currentPage += 1
        isLoading = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        LastfmAPIClient.getTopAlbums(artistName: artist.name ?? "", page: currentPage) { [weak self] (result) in
            switch result {
            case .success(let albums):
                guard let albums = albums else { return }
                self?.albums.append(contentsOf: albums)
                self?.isLoading = false
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumDetails",
            let cell = sender as? AlbumCell,
            let index = collectionView.indexPath(for: cell)?.row,
            let viewController = segue.destination as? AlbumDetailsTableViewController {
            
            viewController.album = albums[index]
        }
    }
}

// MARK: UICollectionViewDelegate
extension AlbumsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if currentPage < numberOfPages && indexPath.row == albums.count - 1 && !isLoading {
            loadAlbums()
        }
    }
}

// MARK: UICollectionViewDataSource
extension AlbumsCollectionViewController {
    
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
        
        if album.image == nil, let url = album.images?.large {
            cell.activityIndicator.startAnimating()
            imageLoader.obtainImageWithPath(imagePath: url.absoluteString) { (image, _) in
                if let cell = collectionView.cellForItem(at: indexPath) as? AlbumCell {
                    cell.albumImageView.image = image
                    cell.activityIndicator.stopAnimating()
                    collectionView.reloadItems(at: [indexPath])
                }
                album.addImage(image)
            }
        } else if let image = album.image {
            cell.albumImageView.image = image
        }
        
        return cell
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
