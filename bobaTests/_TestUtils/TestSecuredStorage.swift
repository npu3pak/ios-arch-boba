//
//  TestSecuredStorage.swift
//  bobaTests
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
@testable import boba

class TestSecuredStorage: PSecuredStorage, PEditableSecuredStorage {
    private static let lockQueue = DispatchQueue(label: "SecuredStorage.Lock")

    var sessionId: String?

    func modify(_ transaction: (PEditableSecuredStorage) -> Void) {
        TestSecuredStorage.lockQueue.sync {
            transaction(self)
        }
    }

    func clear() {
        modify {
            $0.sessionId = nil
        }
    }
}
