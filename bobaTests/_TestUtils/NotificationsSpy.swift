//
//  NotificationsSpy.swift
//  bobaTests
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import XCTest

class NotificationsSpy {
    
    private(set) var expectation: XCTestExpectation

    var subscribers: [Notification.Name: () -> Void] {
        return [:]
    }

    init(_ description: String, fullfillCount: Int) {
        expectation = XCTestExpectation(description: description)
        expectation.expectedFulfillmentCount = fullfillCount
        subscribe()
    }

    deinit {
        disable()
    }

    private func subscribe() {
        for subscriber in subscribers {
            NotificationCenter.default.addObserver(self, selector: #selector(onNotificationReceived), name: subscriber.key, object: nil)
        }
    }

    func disable() {
        NotificationCenter.default.removeObserver(self)
    }

    func wait(_ test: XCTestCase) {
        test.wait(for: [expectation], timeout: 1)
    }

    func recreate(_ description: String, fullfillCount: Int) {
        disable()
        resetSpy()

        expectation = XCTestExpectation(description: description)
        expectation.expectedFulfillmentCount = fullfillCount

        subscribe()
    }

    func resetSpy() {
        XCTFail("Нужно переопределить resetSpy()")
    }

    @objc private func onNotificationReceived(_ notification: Notification) {
        for subscriber in subscribers where subscriber.key == notification.name {
            subscriber.value()
        }
    }

    func fulfill() {
        expectation.fulfill()
    }
}
