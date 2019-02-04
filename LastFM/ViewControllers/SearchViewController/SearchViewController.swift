//
//  SearchViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

protocol SearchViewControllerInteractor: class {
    
}

protocol SearchViewControllerCoordinator: class {
    func showAlbums(artist: Artist)
    func dismiss()
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var searchBar: UISearchBar!
    
    var interactor: SearchViewInteractor!
    weak var coordinator: SearchViewCoordinator?
    
    private var textTimer: Timer?
    private var artists: [Artist] = []
    private var cellId = "ArtistCell"
    private var imageLoader: ImageCacheLoader!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageLoader = ImageCacheLoader()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.dismiss()
        }
    }
    
    @objc func loadResult(_ timer: Timer) {
        guard let text = timer.userInfo as? String, text.count > 0 else {
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        NetworkManager.getArtists(with: text) { [weak self] result in
            switch result {
            case .success(let artists):
                guard let artists = artists else { return }
                self?.artists = artists
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit {
        textTimer?.invalidate()
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if textTimer != nil {
            textTimer?.invalidate()
            textTimer = nil
        }
        textTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(loadResult(_:)),
                                         userInfo: searchText,
                                         repeats: false)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showAlbums(artist: artists[indexPath.row])
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let artist = artists[indexPath.row]
        
        cell.textLabel?.text = artist.name
        cell.imageView?.image = UIImage(named: "placeholder")?.resizedImage(newSize: CGSize(width: 45,
                                                                                           height: 45))
        cell.imageView?.layer.cornerRadius = 22
        cell.imageView?.clipsToBounds = true

        imageLoader.obtainImageWithPath(imagePath: artist.imageUrl![.medium] ?? "") { (image, _) in
            if let updateCell = tableView.cellForRow(at: indexPath) {
                updateCell.imageView?.image = image
            }
        }
        
        return cell
    }
}
