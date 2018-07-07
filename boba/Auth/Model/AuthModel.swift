//
//  AuthModel.swift
//  boba
//
//  Created by Евгений Сафронов on 02.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

class AuthModel {

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: Notifications.logoutRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func sendConfirmationCode(phone: String, onError: @escaping (UserError) -> Void, onSuccess: @escaping () -> Void) {
        onSuccess()
    }

    func authorize(phone: String, confirmationCode: String, onError: @escaping (UserError) -> Void, onSuccess: @escaping () -> Void) {
        onSuccess()
    }

    @objc func logout() {
        // Очищаем данные пользователя

        NotificationCenter.default.post(name: Notifications.Auth.userLoggedOut, object: nil)
    }
}
