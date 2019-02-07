//
//  LastFMAPI.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class LastfmAPIClient {
    
    static let shared = LastfmAPIClient()
    
    private init() {}
    
    let baseURL = "https://ws.audioscrobbler.com/2.0/?"
    let format = "json"
    
    enum APIMethod {
        case getArtists(artist: String, page: Int)
        case getAlbums(artist: String, page: Int)
        case getTracks(artist: String, album: String)
        
        var params: [String: String] {
            switch self {
            case .getArtists(let artist, let page):
                return [APIParameterKey.method: APIMethods.Artist.search.rawValue,
                        APIParameterKey.artist: artist,
                        APIParameterKey.page: String(page)]
            case .getAlbums(let artist, let page):
                return [APIParameterKey.method: APIMethods.Artist.getTopAlbums.rawValue,
                        APIParameterKey.artist: artist,
                        APIParameterKey.page: String(page)]
            case .getTracks(let artist, let album):
                return [APIParameterKey.method: APIMethods.Album.getInfo.rawValue,
                        APIParameterKey.artist: artist,
                        APIParameterKey.album: album]
            }
        }
        
        enum APIMethods {
            enum Artist: String {
                case search = "artist.search"
                case getTopAlbums = "artist.gettopalbums"
            }
            enum Album: String {
                case getInfo = "album.getinfo"
            }
        }
    }
    
    struct APIParameterKey {
        static let method = "method"
        static let artist = "artist"
        static let page = "page"
        static let album = "album"
        static let apiKey = "api_key"
        static let format = "format"
    }
    
    func createURLRequest(method: APIMethod) -> URLRequest? {
        guard let apiKey = LastfmAPIConfiguration.shared.apiKey else { fatalError("API Key is nil") }
        
        var components = URLComponents(string: baseURL)
        components?.setQueryItems(with: method.params)
        components?.queryItems?.append(contentsOf: [
            URLQueryItem(name: APIParameterKey.apiKey, value: apiKey),
            URLQueryItem(name: APIParameterKey.format, value: format)
            ])
        
        guard let url = components?.url else { return nil }
        
        return URLRequest(url: url)
    }
    
//    func getModel<T: Decodable>(method: APIMethod, completion: @escaping (Result<[T]?>) -> Void) {
//        guard let request = createURLRequest(method: method) else { return }
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let data = data {
//                print(data.prettyPrintedJSONString!)
//                do {
//                    let root = try JSONDecoder().decode(T.self, from: data)
//                    let items: [T] = root.model as? [T] ?? [T]()
//                    completion(.success(items))
//                } catch {
//                    completion(.failure(error))
//                }
//            }
//
//            if let error = error {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
}

extension LastfmAPIClient {
    
    func getArtists(with name: String, page: Int = 1, completion: @escaping (Result<[Artist]?>) -> Void) {
        guard let request = LastfmAPIClient.shared.createURLRequest(method: .getArtists(artist: name, page: page)) else { return }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let root = try JSONDecoder().decode(ArtistsRoot.self, from: data)
                    completion(.success(root.artists))
                } catch {
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
            }.resume()
    }
    
    func getTopAlbums(artistName: String, page: Int = 1, completion: @escaping (Result<[Album]?>) -> Void) {
        guard let request = LastfmAPIClient.shared.createURLRequest(method: .getAlbums(artist: artistName, page: page)) else { return }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let root = try JSONDecoder().decode(AlbumsRoot.self, from: data)
                    completion(.success(root.albums))
                } catch {
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
            }.resume()
    }
    
    func getTracks(albumName: String, artistName: String, completion: @escaping (Result<[Track]?>) -> Void) {
        guard let request = LastfmAPIClient.shared.createURLRequest(method: .getTracks(artist: artistName, album: albumName)) else { return }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let root = try JSONDecoder().decode(TracksRoot.self, from: data)
                    completion(.success(root.tracks))
                } catch {
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
            }.resume()
    }
}

class LastfmAPIConfiguration {
    
    static let shared = LastfmAPIConfiguration()
    
    private init() { }
    
    var apiKey: String?
    
    func configure(apiKey: String) {
        self.apiKey = apiKey
    }
}
