//
//  RootFacade.swift
//  boba
//
//  Created by Евгений Сафронов on 07.07.2018.
//  Copyright © 2018 Evgeniy Safronov. All rights reserved.
//

import Foundation

protocol PRootFacadeDelegate: class {
    func showAuth(completion: @escaping () -> Void)
    func showMenu()
}

class RootFacade {

    weak var delegate: PRootFacadeDelegate?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(showAuth), name: Notifications.Auth.userLoggedOut, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        showAuth()
    }

    @objc private func showAuth() {
        delegate?.showAuth { [unowned self] in
            self.delegate?.showMenu()
        }
    }
}
