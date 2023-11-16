//
//  LocalStorage.swift
//  TicketMasterApp
//
//  Created by Jorge Angel Sanchez Martinez on 16/11/23.
//

import Foundation

enum StorageKey: String {
    case apiKey = "apikey"
}
protocol Storage {
    func save(key: StorageKey, value: String)
    func value(for key: StorageKey) -> String?
}

class LocalStorage: Storage {
    static let shared = LocalStorage()

    private init() { }

    func save(key: StorageKey, value: String) {
        UserDefaults.standard.setValue(value, forKey: key.rawValue)
    }
    
    func value(for key: StorageKey) -> String? {
        UserDefaults.standard.string(forKey: key.rawValue)
    }
}
