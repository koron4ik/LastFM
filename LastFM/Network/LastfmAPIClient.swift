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
        case getMobileSession(username: String, password: String, apiSig: String)
        
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
            case .getMobileSession(let username, let password, let apiSig):
                return [APIParameterKey.method: APIMethods.Auth.getMobileSession.rawValue,
                        APIParameterKey.username: username,
                        APIParameterKey.password: password,
                        APIParameterKey.apiSig: apiSig]
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
            enum Auth: String {
                case getMobileSession = "auth.getmobilesession"
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
        static let username = "username"
        static let password = "password"
        static let apiSig = "api_sig"
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
        guard let request = createURLRequest(method: .getArtists(artist: name, page: page)) else { return }
        
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
        guard let request = createURLRequest(method: .getAlbums(artist: artistName, page: page)) else { return }
        
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
        guard let request = createURLRequest(method: .getTracks(artist: artistName, album: albumName)) else { return }
        
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
    
    func getMobileSession(username: String, password: String, completion: @escaping (Result<Session?>) -> Void) {
        
        let apiSig = "\(APIParameterKey.apiKey)\(LastfmAPIConfiguration.shared.apiKey ?? "")method\(APIMethod.APIMethods.Auth.getMobileSession.rawValue)password\(password)username\(username)\(LastfmAPIConfiguration.shared.apiSecret ?? "")".md5()
        
        guard var request = createURLRequest(method: .getMobileSession(username: username, password: password, apiSig: apiSig)) else { return }
        
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let data = data {
                do {
                    let session = try JSONDecoder().decode(Session.self, from: data)
                    completion(.success(session))
                } catch {
                    completion(.failure(error))
                }
            }
            
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
//    private func getToken(completion: @escaping (_ token: String) -> Void) {
//        guard let url = URL(string: "http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=\(LastfmAPIConfiguration.shared.apiKey!)&format=json") else {
//            return
//        }
//        let request = URLRequest(url: url)
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if let data = data {
//                do {
//                    if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        if let accessToken = dict["token"] as? String {
//                            completion(accessToken)
//                        }
//                    }
//                } catch {}
//            }
//            }.resume()
//    }
}

class LastfmAPIConfiguration {
    
    static let shared = LastfmAPIConfiguration()
    
    private init() { }
    
    var apiKey: String?
    var apiSecret: String?
    
    func configure(apiKey: String, apiSecret: String) {
        self.apiKey = apiKey
        self.apiSecret = apiSecret
    }
}
