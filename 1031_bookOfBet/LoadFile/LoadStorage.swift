//
//  LoadStorage.swift
//  1031_bookOfBet
//
//  Created by Владимир Кацап on 07.10.2024.
//

import Foundation


class LoadDataFromFile {
    
    //loadProfile
    func loadProfileFromFile() -> Profile? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("profile.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let profile = try JSONDecoder().decode(Profile.self, from: data)
            return profile
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    //save profile
    func saveProfileToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("profile.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    
    
}
