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
    private var selectedAlbumsIndexes = [IndexPath]()
    private let imageLoader = ImageCacheLoader()
    private let reuseIdentifier = "AlbumCell"
    
    private var editMode = false {
        didSet {
            navigationController?.isToolbarHidden = !editMode
            navigationController?.navigationBar.topItem?.title = editMode ? "Choosing" : "Albums"
            navigationItem.setHidesBackButton(editMode, animated: true)
            navigationItem.rightBarButtonItems?[1] = UIBarButtonItem(barButtonSystemItem: editMode ? .cancel : .edit, target: self, action: #selector(editButtonPressed(_:)))
            
            if !editMode {
                selectedAlbumsIndexes.removeAll()
                collectionView.reloadData()
            }
        }
    }
    
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

        self.collectionView.allowsMultipleSelection = true
        self.collectionView.collectionViewLayout = AlbumsColletionViewFlowLayout(frame: view.frame, itemsPerRow: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        albums = CoreDataManager.shared.loadAlbums().sorted { $0.name ?? "" < $1.name ?? "" }
        collectionView.reloadData()
        collectionView.backgroundView = backgroundView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        editMode = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumDetails",
            let cell = sender as? FavouriteAlbumCell,
            let index = collectionView.indexPath(for: cell)?.row,
            let viewController = segue.destination as? AlbumDetailsTableViewController {
            
            viewController.album = Album(albumCoreData: albums[index])
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer!) {
        if gesture.state != .ended {
            return
        }
        
        let point = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: point), !editMode {
            let cell = self.collectionView.cellForItem(at: indexPath) as? FavouriteAlbumCell
            selectedAlbumsIndexes.append(indexPath)
            cell?.layer.borderWidth = 2.0
            cell?.checkMarkImageView.isHidden = false
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            editMode = true
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        editMode = !editMode
    }
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        let filteredAlbums = selectedAlbumsIndexes.compactMap { Album(albumCoreData: self.albums[$0.row]) }
        selectedAlbumsIndexes.forEach { albums.remove(at: $0.row) }
        filteredAlbums.forEach { CoreDataManager.shared.deleteAlbum($0) }
        
        collectionView.deleteItems(at: selectedAlbumsIndexes)
        collectionView.reloadData()
        editMode = false
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
        cell.layer.borderColor = UIColor.blue.cgColor
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        cell.addGestureRecognizer(gesture)
        
        return cell
    }

}

// MARK: UICollectioViewDelegate
extension MainCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FavouriteAlbumCell
        
        if editMode {
            selectedAlbumsIndexes.append(indexPath)
            cell?.layer.borderWidth = 2.0
            cell?.checkMarkImageView.isHidden = false
            toolbarItems?[1].isEnabled = true
        } else {
            self.performSegue(withIdentifier: "albumDetails", sender: cell)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FavouriteAlbumCell
        
        if editMode {
            selectedAlbumsIndexes = selectedAlbumsIndexes.filter { $0 != indexPath }
            cell?.layer.borderWidth = 0.0
            cell?.checkMarkImageView.isHidden = true
            
            if selectedAlbumsIndexes.count == 0 {
                toolbarItems?[1].isEnabled = false
            }
        } else {
            self.performSegue(withIdentifier: "albumDetails", sender: cell)
        }
    }
    
}
