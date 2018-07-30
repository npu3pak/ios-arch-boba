//
//  TestPreferencesStorage.swift
//  bobaTests
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
@testable import boba

class TestPreferencesStorage: PPreferencesStorage, PEditablePreferencesStorage {

    private static let lockQueue = DispatchQueue(label: "PreferencesStorage.Lock")

    var example: String?

    func modify(transaction: (PEditablePreferencesStorage) -> Void) {
        TestPreferencesStorage.lockQueue.sync {
            transaction(self)
        }
    }

    func clear() {
        TestPreferencesStorage.lockQueue.sync {
            example = nil
        }
    }
}
