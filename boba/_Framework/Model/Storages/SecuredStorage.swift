//
//  SecuredStorage.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import KeychainSwift

protocol PSecuredStorage: class {
    var sessionId: String? {get}

    func modify(_ transaction: (PEditableSecuredStorage) -> Void)
    func clear()
}

protocol PEditableSecuredStorage: class {
    var sessionId: String? {get set}
}

class SecuredStorage: PSecuredStorage, PEditableSecuredStorage {

    private static let lockQueue = DispatchQueue(label: "SecuredStorage.Lock")
    private lazy var keychain = KeychainSwift()

    var sessionId: String?
    private static let keySessionId = "sessionId"

    private init() { }

    static var instance: PSecuredStorage = SecuredStorage.load()

    private static func load() -> SecuredStorage {
        let keychain = KeychainSwift()

        let storage = SecuredStorage()
        storage.sessionId = keychain.get(keySessionId)
        return storage
    }

    func modify(_ transaction: (PEditableSecuredStorage) -> Void) {
        SecuredStorage.lockQueue.sync {
            transaction(self)
            save()
        }
    }

    private func save() {
        let keychain = KeychainSwift()

        self.save(key: SecuredStorage.keySessionId, value: self.sessionId, keychain: keychain)
    }

    private func save(key: String, value: String?, keychain: KeychainSwift) {
        if let value = value {
            keychain.set(value, forKey: key, withAccess: .accessibleAlwaysThisDeviceOnly)
        } else {
            keychain.delete(key)
        }
    }

    func clear() {
        modify {
            $0.sessionId = nil
        }
    }
}
