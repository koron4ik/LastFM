//
//  ImageCacheLoader.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import UIKit

class ImageCacheLoader {
    
    var task: URLSessionDataTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        self.session = URLSession.shared
        self.task = URLSessionDataTask()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        }

        if let url = URL(string: imagePath) {
            task = session.dataTask(with: url) { [weak self] (data, _, error) in
                if let error = error {
                    completionHandler(nil, error)
                }
                
                if let data = data, let image = UIImage(data: data) {
                    self?.cache.setObject(image, forKey: imagePath as NSString)
                    DispatchQueue.main.async {
                        completionHandler(image, nil)
                    }
                }
            }
            task.resume()
        }
    }
}
