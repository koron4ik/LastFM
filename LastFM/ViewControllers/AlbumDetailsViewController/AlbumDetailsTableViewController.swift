//
//  AlbumDetailsViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/3/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol AlbumDetailsTableViewControllerInteractor: class {
    var album: Album { get }
}

protocol AlbumDetailsTableViewControllerCoordinator: class {
    func dismiss()
}

class AlbumDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var interactor: AlbumDetailsTableViewInteractor!
    weak var coordinator: AlbumDetailsTableViewCoordinator?
    private var imageLoader = ImageCacheLoader()
        
    private var isFavourite = false {
        didSet {
            let image = isFavourite ? UIImage(named: "favorite") : UIImage(named: "unfavorite")
            favouriteButton.setImage(image, for: .normal)
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
        
        if isFavourite { CoreDataManager.shared.updateAlbum(interactor.album) }
        if isMovingFromParent { coordinator?.dismiss() }
    }
    
    private func configureHeaderView() {
        albumNameLabel.text = interactor.album.name
        artistNameLabel.text = interactor.album.artist?.name
        
        isFavourite = CoreDataManager.shared.albumIsExist(interactor.album)
        
        if let image = interactor.album.image {
            self.albumImageView.image = image
        } else if let url = interactor.album.images?.extralarge {
            self.imageActivityIndicator.startAnimating()
            imageLoader.obtainImageWithPath(imagePath: url.absoluteString) { [weak self] (image, _) in
                self?.imageActivityIndicator.stopAnimating()
                guard let image = image else { return }
                self?.albumImageView.image = image
                self?.interactor.album.addImage(image)
            }
        }
    }
    
    private func configureTableView() {
        if interactor.album.tracks?.count ?? 0 != 0 {
            self.tableView.reloadData()
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            tableViewActivityIndicator.startAnimating()
            LastfmAPIClient.getTracks(albumName: interactor.album.name ?? "", artistName: interactor.album.artist?.name ?? "") { [weak self] (result) in
                switch result {
                case .success(let tracks):
                    if let tracks = tracks {
                        DispatchQueue.main.async {
                            self?.interactor.album.addTracks(tracks)
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
    }
    
    @IBAction func favouriteButtonPressed(_ sender: Any) {
        if isFavourite {
            CoreDataManager.shared.deleteAlbum(interactor.album)
        } else {
            CoreDataManager.shared.saveAlbumToFavourite(interactor.album)
        }
        isFavourite = !isFavourite
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.album.tracks?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { return UITableViewCell() }
        
        if let tracks = interactor.album.tracks {
            cell.trackNumberLabel.text = String(indexPath.row + 1)
            cell.trackTitleLabel.text = tracks[indexPath.row].name
        }
        
        return cell
    }
}
