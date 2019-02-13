//
//  Image.swift
//  LastFM
//
//  Created by Vadim Koronchik on 2/2/19.
//  Copyright © 2019 Vadim Koronchik. All rights reserved.
//

import Foundation

class Images: Decodable {
    var small: URL?
    var medium: URL?
    var large: URL?
    var extralarge: URL?
    var mega: URL?
    
    enum Size: String, Codable {
        case small
        case medium
        case large
        case extralarge
        case mega
    }
    
    struct ImageDecodable: Decodable {
        let text: String
        let size: Size
        
        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }
    }
    
    init?(imageCoreData: ImagesCoreData) {
        self.small = URL(string: imageCoreData.small ?? "")
        self.medium = URL(string: imageCoreData.medium ?? "")
        self.large = URL(string: imageCoreData.large ?? "")
        self.extralarge = URL(string: imageCoreData.extralarge ?? "")
        self.large = URL(string: imageCoreData.mega ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        while !unkeyedContainer.isAtEnd {
            let image = try unkeyedContainer.decode(ImageDecodable.self)
            let url = URL(string: image.text)
            switch image.size {
            case .small:
                self.small = url
            case .medium:
                self.medium = url
            case .large:
                self.large = url
            case .extralarge:
                self.extralarge = url
            case .mega:
                self.mega = url
            }
        }
    }
}
