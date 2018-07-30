//
//  FacadeSpy.swift
//  bobaTests
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import XCTest
import Foundation

class FacadeSpy {

    private(set) var expectation: XCTestExpectation
    private(set) var fullfillCount: Int

    init(_ description: String, fullfillCount: Int) {
        expectation = XCTestExpectation(description: description)
        if fullfillCount > 0 {
            expectation.expectedFulfillmentCount = fullfillCount
        }
        self.fullfillCount = fullfillCount
    }

    func recreate(_ description: String, fullfillCount: Int) {
        expectation = XCTestExpectation(description: description)
        if fullfillCount > 0 {
            expectation.expectedFulfillmentCount = fullfillCount
        }
        self.fullfillCount = fullfillCount
        resetSpy()
    }

    func wait(_ test: XCTestCase) {
        if fullfillCount > 0 {
            test.wait(for: [expectation], timeout: 1)
        }
    }

    func fulfill() {
        expectation.fulfill()
    }

    func resetSpy() {
        XCTFail("Нужно переопределить resetSpy()")
    }
}
