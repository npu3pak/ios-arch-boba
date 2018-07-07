//
//  Notifications+Auth.swift
//  boba
//
//  Created by Евгений Сафронов on 07.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

extension Notifications {
    struct Auth {
        static let userLoggedOut = Notification.Name(rawValue: "Auth.userLoggedOut")
    }
}
