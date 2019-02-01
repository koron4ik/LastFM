//
//  NetworkManager.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/1/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static func getArtists(with name: String, limit: Int = 30, page: Int = 1, completion: @escaping (Result<[Artist]?>) -> Void ) {
        guard let api = LastFMAPIConfiguration.shared.apiKey else {
            fatalError("api key isn't exist")
        }
        let str = "\(Constants.apiUrl)?method=artist.search&artist=\(name)&api_key=\(api)&format=json"
        guard let url = URL(string: str) else { return }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let root = try JSONDecoder().decode(Root.self, from: data)
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
}
