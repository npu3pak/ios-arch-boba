//
//  Test.swift
//  bobaTests
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation
import XCTest

class Step<A> {

    private let args: A

    fileprivate init(args: A) {
        self.args = args
    }

    func step<N>(_ next: N.Type, _ action: @escaping (A) -> N) -> Step<N> {
        let result: N = action(args)
        return Step<N>(args: result)
    }

    func asyncStep<N>(_ next: N.Type, _ action: @escaping (A, @escaping (N) -> Void) -> Void) -> Step<N> {
        let group = DispatchGroup()
        group.enter()
        var result: N?
        action(args) {
            result = $0
            group.leave()
        }
        return Step<N>(args: result!)
    }

    func assert(action: @escaping (A) -> Void) {
        action(args)
    }
}

func prepare<N>(_ next: N.Type, _ action: @escaping () -> N) -> Step<N> {
    let result: N = action()
    return Step<N>(args: result)
}

class Test {

    private let id: String
    private let description: String
    private let parentTest: XCTestCase
    private let lockQ: DispatchQueue

    init(_ description: String, test: XCTestCase) {
        self.id = UUID().uuidString
        self.description = description
        self.parentTest = test
        self.lockQ = DispatchQueue(label: id)
    }

    static func unexpectedError(_ error: Error) {
        XCTFail("TEST_ERROR: \(error)")
    }

    func precondition(_ action: @escaping (_ completion: @escaping () -> Void) -> Void) {
        lockQ.sync {
            let e = XCTestExpectation(description: "\(self.description). TEST_PRECONDITION. ID:\(self.id)")
            action(e.fulfill)
            self.parentTest.wait(for: [e], timeout: 1)
        }
    }

    func async(_ action: @escaping (_ completion: @escaping () -> Void) -> Void) {
        lockQ.sync {
            let e = XCTestExpectation(description: "\(self.description). TEST_ASYNC STEP. ID:\(self.id)")
            action(e.fulfill)
            self.parentTest.wait(for: [e], timeout: 1)
        }
    }

    func action<T1, T2>(_ action: @escaping (T1) -> T2) -> ((T1) -> T2) {
        return action
    }

    func sync(_ action: @escaping () -> Void) {
        lockQ.sync {
            action()
        }
    }

    func check(_ action: @escaping () -> Void) {
        lockQ.sync {
            action()
        }
    }
}
