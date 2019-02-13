//
//  MainViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class MainCollectionViewController: UICollectionViewController {
        
    private var albums: [AlbumCoreData] = []
    private let imageLoader = ImageCacheLoader()
    private let reuseIdentifier = "AlbumCell"
    
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

        self.collectionView.collectionViewLayout = AlbumsColletionViewFlowLayout(frame: view.frame, itemsPerRow: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        albums = CoreDataManager.shared.loadAlbums()
        collectionView.reloadData()
        collectionView.backgroundView = backgroundView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumDetails",
            let cell = sender as? FavouriteAlbumCell,
            let index = collectionView.indexPath(for: cell)?.row,
            let viewController = segue.destination as? AlbumDetailsTableViewController {
            
            viewController.album = Album(albumCoreData: albums[index])
        }
    }
    
    deinit {
        LastfmAuth.auth.logout()
    }
}

// MARK: UICollectioViewDataSource
extension MainCollectionViewController {
    
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

}
