//
//  Constants.swift
//  boba
//
//  Created by Евгений Сафронов on 04.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

struct Constants {

    struct Masks {
        static let phone = "(999) 999-99-99"
        static let authConfirmationCode = "99999"
    }

    struct Regexp {
        static let phone = "^\\d{10}$"
        static let authConfirmationCode = "^\\d{5}$"
    }

    struct TestAccount {
        static let phone = "9009000000"
        static let authConfirmationCode = "12345"
    }
}
