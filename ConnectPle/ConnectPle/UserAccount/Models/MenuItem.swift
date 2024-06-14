//
//  MenuItem.swift
//  ConnectPle
//
//  Created by Nolan Chen on 6/10/24.
//

import Foundation
class MenuItem: Codable {
    private var rate: Int
    private var imageURL: String
    
    init(rate: Int, imageURL: String) {
        self.rate = rate
        self.imageURL = imageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case rate
        case imageURL
    }
    
    // Encode properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rate, forKey: .rate)
        try container.encode(imageURL, forKey: .imageURL)
    }
    
    // Decode properties
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rate = try container.decode(Int.self, forKey: .rate)
        imageURL = try container.decode(String.self, forKey: .imageURL)
    }
    
    // Getter methods to access private properties
    func getRate() -> Int {
        return rate
    }
    func setRate(newRate: Int?) {
        self.rate = newRate ?? self.rate
    }
    
    func getImageURL() -> String {
        return imageURL
    }
    func setNewImageURL(newImageURL: String?) {
        self.imageURL = newImageURL ?? self.imageURL
    }
}
