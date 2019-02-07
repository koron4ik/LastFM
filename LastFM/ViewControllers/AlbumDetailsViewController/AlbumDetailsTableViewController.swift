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
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var interactor: AlbumDetailsTableViewInteractor!
    weak var coordinator: AlbumDetailsTableViewCoordinator?
        
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
        
        if isMovingFromParent { coordinator?.dismiss() }
        if isFavourite { CoreDataManager.shared.saveContext() }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    private func configureHeaderView() {
        albumNameLabel.text = interactor.album.name
        artistNameLabel.text = interactor.album.artist?.name
        
        isFavourite = CoreDataManager.shared.albumIsExist(interactor.album)
        
        if let imageData = interactor.album.image as Data? {
            self.albumImageView.image = UIImage(data: imageData)
        } else if let url = interactor.album.images?.extralarge {
            URLSession.shared.dataTask(with: url) { [weak self] (data, _, _) in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.albumImageView.image = image
                    self?.interactor.album.addImageData(data)
                }
            }.resume()
        }
        
    }
    
    private func configureTableView() {
        if interactor.album.tracks?.allObjects.count ?? 0 != 0 {
            self.tableView.reloadData()
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            LastfmAPIClient.shared.getTracks(albumName: interactor.album.name ?? "", artistName: interactor.album.artist?.name ?? "") { [weak self] (result) in
                switch result {
                case .success(let tracks):
                    guard let tracks = tracks else { return }
                    self?.interactor.album.addTracks(tracks)
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
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
        return interactor.album.tracks?.allObjects.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as? TrackCell else { return UITableViewCell() }
        
        if let tracks = interactor.album.tracks?.allObjects as? [Track] {
            cell.trackNumberLabel.text = String(indexPath.row + 1)
            cell.trackTitleLabel.text = tracks[indexPath.row].name
        }
        
        return cell
    }
}
