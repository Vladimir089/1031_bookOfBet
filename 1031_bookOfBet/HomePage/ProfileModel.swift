//
//  ProfileModel.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import Foundation


struct Profile: Codable {
    var image: Data
    var name: String
    
    init(image: Data, name: String) {
        self.image = image
        self.name = name
    }
}
