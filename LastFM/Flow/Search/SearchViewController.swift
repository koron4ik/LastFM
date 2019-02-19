//
//  SearchViewController.swift
//  LastFM
//
//  Created by Vadim Koronchik on 1/31/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search artists"
        controller.searchBar.delegate = self
        
        return controller
    }()
    
    private var backgroundView: UIImageView {
        let background = UIImageView()
        background.contentMode = .scaleAspectFill
        background.image = UIImage(named: "search_view")
        
        return background
    }
        
    private var textTimer: Timer?
    private var artists: [Artist] = []
    private var cellId = "ArtistCell"
    private var imageLoader = ImageCacheLoader()
    private var currentPage = 0
    private let numberOfPages = 3
    private var isLoading = false
    private var searchText: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView = backgroundView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    @objc func search(_ timer: Timer) {
        guard let text = timer.userInfo as? String, text.count > 0 else {
            return
        }
        
        searchText = text
        currentPage = 0
        loadArtists()
    }
        
    func loadArtists() {
        currentPage += 1
        isLoading = true
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        LastfmAPIClient.getArtists(with: searchText, page: currentPage) { [weak self] result in
            switch result {
            case .success(let artists):
                guard let artists = artists else { return }
                self?.artists.append(contentsOf: artists)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.isLoading = false
                    if self?.artists.count != 0 {
                        self?.tableView.backgroundView = UIImageView()
                    } else {
                        self?.tableView.backgroundView = UIImageView(image: UIImage(named: "not_found"))
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self?.tableView.backgroundView = UIImageView(image: UIImage(named: "not_found"))
                }
                
            }
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        searchController.searchBar.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albums",
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPath(for: cell)?.row,
            let viewController = segue.destination as? AlbumsCollectionViewController {
            
            viewController.artist = artists[index]
        }
    }
    
    deinit {
        textTimer?.invalidate()
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        artists.removeAll()
        tableView.reloadData()
        tableView.backgroundView = backgroundView
        
        if textTimer != nil {
            textTimer?.invalidate()
            textTimer = nil
        }
        textTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(search),
                                         userInfo: searchText,
                                         repeats: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.backgroundView = backgroundView
    }
}

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if currentPage < numberOfPages && indexPath.row == artists.count - 1 && !isLoading {
            loadArtists()
        }
    }

}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let artist = artists[indexPath.row]
        
        cell.textLabel?.text = artist.name
        cell.imageView?.image = UIImage(named: "placeholder")?.resizedImage(newSize: CGSize(width: 45,
                                                                                            height: 45))
        
        imageLoader.obtainImageWithPath(imagePath: artist.image?.medium?.absoluteString ?? "") { (image, _) in
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.imageView?.image = image
            }
        }
        
        return cell
    }
}
