//
//  PreferencesStorage.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

protocol PPreferencesStorage: class {
    var example: String? {get}

    func modify(transaction: (_: PEditablePreferencesStorage) -> Void)
    func clear()
}

protocol PEditablePreferencesStorage: class {
    var example: String? {get set}
}

class PreferencesStorage: PPreferencesStorage, PEditablePreferencesStorage {
    private static let lockQueue = DispatchQueue(label: "PreferencesStorage.Lock")

    var example: String?
    private static let keyExample = "example"

    private init() {
    }

    static var instance: PPreferencesStorage = PreferencesStorage.load()

    private static func load() -> PreferencesStorage {
        let defaults = UserDefaults.standard
        let storage = PreferencesStorage()
        storage.example = defaults.string(forKey: PreferencesStorage.keyExample)
        return storage
    }

    func modify(transaction: (PEditablePreferencesStorage) -> Void) {
        PreferencesStorage.lockQueue.sync {
            transaction(self)
            save()
        }
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(example, forKey: PreferencesStorage.keyExample)
        defaults.synchronize()
    }

    func clear() {
        PreferencesStorage.lockQueue.sync {
            example = nil

            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: PreferencesStorage.keyExample)
            defaults.synchronize()
        }
    }
}
