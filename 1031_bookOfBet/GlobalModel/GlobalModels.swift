//
//  GlobalModels.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 08.10.2024.
//

import Foundation

struct Bids: Codable, Identifiable {
    let id: UUID
    var cofficent: String
    var nameMatch: String
    var nameStavka: String
    var stavka: String
    var rezult: Bool
    var isCompleted: Bool
    
    init(cofficent: String, nameMatch: String, nameStavka: String, stavka: String, rezult: Bool, isCompleted: Bool) {
        self.id = UUID()
        self.cofficent = cofficent
        self.nameMatch = nameMatch
        self.nameStavka = nameStavka
        self.stavka = stavka
        self.rezult = rezult
        self.isCompleted = isCompleted
    }
}

struct Event: Codable, Identifiable {
    let id: UUID
    var date: String
    var time: String
    var bids: [Bids]
    var cetegor: String
    var oneComand: String
    var secondComand: String
    var notes: [Note]
    
    init(date: String, time: String, bids: [Bids], cetegor: String, oneComand: String, secondComand: String, notes: [Note]) {
        self.id = UUID()
        self.date = date
        self.time = time
        self.bids = bids
        self.cetegor = cetegor
        self.oneComand = oneComand
        self.secondComand = secondComand
        self.notes = notes
    }
}


struct Note: Codable {
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}
