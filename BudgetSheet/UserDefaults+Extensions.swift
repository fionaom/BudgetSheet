//
//  UserDefaults+Extensions.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 23/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import Foundation


extension UserDefaults {
    func set<T: Encodable>(codable: T, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codable)
            let jsonString = String(data: data, encoding: .utf8)!
            print("Saving \"\(key)\": \(jsonString)")
            self.set(jsonString, forKey: key)
        } catch {
            print("Saving \"\(key)\" failed: \(error)")
        }
    }
    
    func codable<T: Decodable>(_ codable: T.Type, forKey key: String) -> T? {
        guard let jsonString = self.string(forKey: key) else { return nil }
        guard let data = jsonString.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        print("Loading \"\(key)\": \(jsonString)")
        return try? decoder.decode(codable, from: data)
    }
}
