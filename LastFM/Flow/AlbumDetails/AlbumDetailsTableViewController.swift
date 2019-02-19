//
//  AlbumDetailsViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/3/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class AlbumDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    
    var album: Album!
    private var imageLoader = ImageCacheLoader()

    private var isFavourite = false {
        didSet {
            let image = isFavourite ? UIImage(named: "favorite") : UIImage(named: "unfavorite")
            favouriteButton.image = image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
        configureTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if isFavourite {
            CoreDataManager.shared.updateAlbum(album)
        }
    }
    
    private func configureHeaderView() {
        albumNameLabel.text = album.name
        artistNameLabel.text = album.artist?.name
        
        isFavourite = CoreDataManager.shared.albumIsExist(album)
        
        if let data = album.imageData {
            self.albumImageView.image = UIImage(data: data)
        } else if let url = album.image?.extralarge {
            self.imageActivityIndicator.startAnimating()
            imageLoader.obtainImageWithPath(imagePath: url.absoluteString) { [weak self] (image, _) in
                self?.imageActivityIndicator.stopAnimating()
                guard let image = image else { return }
                self?.albumImageView.image = image
                self?.album.addImage(image)
            }
        }
    }
    
    private func configureTableView() {
        album.tracks?.count ?? 0 != 0 ? tableView.reloadData() : fetchTracks()
    }
    
    private func fetchTracks() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        tableViewActivityIndicator.startAnimating()
        LastfmAPIClient.getTracks(albumName: album.name ?? "", artistName: album.artist?.name ?? "") { [weak self] (result) in
            switch result {
            case .success(let tracks):
                if let tracks = tracks {
                    DispatchQueue.main.async {
                        self?.album.addTracks(tracks)
                        self?.tableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self?.tableViewActivityIndicator.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        if isFavourite {
            CoreDataManager.shared.deleteAlbum(album)
        } else {
            CoreDataManager.shared.saveAlbumToFavourite(album)
        }
        isFavourite = !isFavourite
    }
    
}

// MARK: UITableViewDataSource
extension AlbumDetailsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.tracks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { return UITableViewCell() }
        
        if let tracks = album.tracks {
            cell.trackNumberLabel.text = String(indexPath.row + 1)
            cell.trackTitleLabel.text = tracks[indexPath.row].name
        }
        
        return cell
    }
    
}
