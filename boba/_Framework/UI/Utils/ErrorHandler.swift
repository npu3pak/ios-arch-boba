//
//  ErrorHandler.swift
//  boba
//
//  Created by Евгений Сафронов on 03.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import UIKit

class ErrorHandler {

    private var controller: UIViewController

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showError(_ error: UserError, completion: (() -> Void)? = nil) {
        showError(error, completion: completion, onClose: nil)
    }

    func showError(_ error: UserError, completion: (() -> Void)? = nil, onClose: (() -> Void)? = nil) {
        switch error {
        case .message(let message, let error): showMessage(message, cause: error, completion: completion, onClose: onClose)
        case .fault(code: let code, message: let message): showFault(code: code, message: message, completion: completion, onClose: onClose)
        case .authenticate: authenticate(completion: completion)
        case .noConnection: showNoConnection(completion: completion, onClose: onClose)
        }
    }

    private func showMessage(_ message: String?, cause: Error?, completion: (() -> Void)?, onClose: (() -> Void)?) {
        if cause != nil {
            print(cause!)
        }

        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in onClose?() }))

        controller.present(alert, animated: true, completion: completion)
    }

    private func showFault(code: Int, message: String?, completion: (() -> Void)?, onClose: (() -> Void)?) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in onClose?() }))

        controller.present(alert, animated: true, completion: completion)
    }

    private func authenticate(completion: (() -> Void)?) {
        NotificationCenter.default.post(name: Notifications.logoutRequired, object: nil)
        completion?()
    }

    private func showNoConnection(completion: (() -> Void)?, onClose: (() -> Void)?) {
        let message = "Нет доступа к сети Интернет"
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in onClose?() }))
        alert.addAction(UIAlertAction(title: "Настройки", style: .default, handler: { [weak self] _ in
            self?.showAppPreferences()
            onClose?()
        }))
        controller.present(alert, animated: true, completion: completion)
    }

    private func showAppPreferences() {
        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}
